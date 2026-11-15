import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/services/rating_api_service.dart';
import '../../service/tmdb_movie_service.dart';
import '../../model/tmdb_movie_dto.dart';
import '../data/models/rating_with_movie.dart';
import 'auth_view_model.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this._authViewModel,
    this.memberId,
  );

  final AuthViewModel _authViewModel;

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final int memberId;

  final Map<int, TmdbMovieDto?> _movieCache = {};

  int _requestVersion = 0;
  bool _disposed = false;

  bool isUpdating = false;
  final Set<int> deletingRatingIds = {};

  List<RatingWithMovie> ratings = const [];

  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;
  String? refreshWarning;

  final Set<int> selectedRatingIds = {};
  bool isDeletingSelected = false;

  bool get isWriting =>
      isUpdating || deletingRatingIds.isNotEmpty || isDeletingSelected;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool _isAuthExpired(DioException error) {
    final data = error.response?.data;
    final code = data is Map ? data['code']?.toString() : null;

    return code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';
  }

  Future<void> _handleAuthExpired(DioException error) async {
    if (_isAuthExpired(error)) {
      await _authViewModel.expireSession();
    }
  }

  Future<void> load() async {
    if (_disposed) return;

    final version = ++_requestVersion;

    status = MyRatingsLoadStatus.loading;
    message = null;
    _notify();

    try {
      final rawRatings = await _service.fetchMyRatings(memberId);

      if (_disposed || version != _requestVersion) return;

      final entries = <RatingWithMovie>[];
      var missingMovies = 0;

      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion) return;

        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] = await _movieService.findMovieById(
              rating.movieId,
            );
          } catch (_) {
            // 영화 정보 조회 실패는 캐시하지 않아 재시도할 수 있게 한다.
          }
        }

        final movie = _movieCache[rating.movieId];

        if (movie == null) {
          missingMovies++;
        }

        entries.add(RatingWithMovie(rating: rating, movie: movie));
      }

      if (_disposed || version != _requestVersion) return;

      ratings = entries;

      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;

      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
      }
    } on DioException catch (error) {
      if (_disposed || version != _requestVersion) return;

      status = MyRatingsLoadStatus.error;
      message = writeMyRatingsErrorMessage(error);
    } catch (_) {
      if (_disposed || version != _requestVersion) return;

      status = MyRatingsLoadStatus.error;
      message = '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
    }

    if (!_disposed && version == _requestVersion) {
      _notify();
    }
  }

  // 조회 실패 화면의 다시 시도 버튼에서 사용
  Future<void> retryLoad() async {
    await load();
  }

  Future<void> _refreshAfterWrite() async {
    await load();

    if (_disposed) return;

    if (status == MyRatingsLoadStatus.error) {
      refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
    } else {
      refreshWarning = null;
    }

    _notify();
  }

  void toggleRatingSelection(int ratingId) {
    if (_disposed || isDeletingSelected || isUpdating) return;

    if (selectedRatingIds.contains(ratingId)) {
      selectedRatingIds.remove(ratingId);
    } else {
      selectedRatingIds.add(ratingId);
    }

    _notify();
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    if (_disposed ||
        isUpdating ||
        isDeletingSelected ||
        deletingRatingIds.contains(ratingId)) {
      return;
    }

    if (_authViewModel.status != AuthStatus.signedIn) {
      message = '로그인이 필요합니다.';
      _notify();
      return;
    }

    final sessionVersion = _authViewModel.sessionVersion;

    isUpdating = true;
    refreshWarning = null;
    message = null;
    _notify();

    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );

      if (_disposed || sessionVersion != _authViewModel.sessionVersion) {
        return;
      }

      // 서버에서 받은 수정 결과를 현재 목록에 먼저 반영
      ratings = ratings.map((entry) {
        if (entry.rating.ratingId == ratingId) {
          return RatingWithMovie(rating: updated, movie: entry.movie);
        }
        return entry;
      }).toList();

      _notify();

      await _refreshAfterWrite();
    } on DioException catch (error) {
      if (_disposed || sessionVersion != _authViewModel.sessionVersion) {
        return;
      }

      if (_isAuthExpired(error)) {
        await _handleAuthExpired(error);
        return;
      }

      message = writeErrorMessage(error);
      _notify();

      if (shouldRefreshAfterRatingError(error)) {
        await load();
      }

      rethrow;
    } finally {
      if (!_disposed) {
        isUpdating = false;
        _notify();
      }
    }
  }

  Future<void> deleteRating(int ratingId) async {
    if (_disposed ||
        isDeletingSelected ||
        isUpdating ||
        deletingRatingIds.contains(ratingId)) {
      return;
    }

    if (_authViewModel.status != AuthStatus.signedIn) {
      message = '로그인이 필요합니다.';
      _notify();
      return;
    }

    final sessionVersion = _authViewModel.sessionVersion;

    deletingRatingIds.add(ratingId);
    refreshWarning = null;
    message = null;
    _notify();

    try {
      await _service.deleteRating(ratingId);

      if (_disposed || sessionVersion != _authViewModel.sessionVersion) {
        return;
      }

      selectedRatingIds.remove(ratingId);

      await _refreshAfterWrite();
    } on DioException catch (error) {
      if (_disposed || sessionVersion != _authViewModel.sessionVersion) {
        return;
      }

      if (_isAuthExpired(error)) {
        await _handleAuthExpired(error);
        return;
      }

      message = writeErrorMessage(error);
      _notify();

      if (shouldRefreshAfterRatingError(error)) {
        await load();
      }

      rethrow;
    } finally {
      if (!_disposed) {
        deletingRatingIds.remove(ratingId);
        _notify();
      }
    }
  }

  Future<void> deleteSelectedRatings() async {
    if (_disposed ||
        isDeletingSelected ||
        isUpdating ||
        selectedRatingIds.isEmpty) {
      return;
    }

    if (_authViewModel.status != AuthStatus.signedIn) {
      message = '로그인이 필요합니다.';
      _notify();
      return;
    }

    final sessionVersion = _authViewModel.sessionVersion;

    isDeletingSelected = true;
    refreshWarning = null;
    message = null;
    _notify();

    var failed = 0;
    var authExpired = false;

    final idsToDelete = selectedRatingIds.toList();

    try {
      for (final ratingId in idsToDelete) {
        if (_disposed || sessionVersion != _authViewModel.sessionVersion) {
          return;
        }

        try {
          await _service.deleteRating(ratingId);

          if (_disposed || sessionVersion != _authViewModel.sessionVersion) {
            return;
          }

          selectedRatingIds.remove(ratingId);
        } on DioException catch (error) {
          if (_isAuthExpired(error)) {
            authExpired = true;
            await _handleAuthExpired(error);
            break;
          }

          failed++;
        } catch (_) {
          failed++;
        }
      }

      if (_disposed || sessionVersion != _authViewModel.sessionVersion) {
        return;
      }

      await _refreshAfterWrite();

      if (_disposed) return;

      if (authExpired) {
        message = '로그인이 만료됐어요. 다시 로그인해 주세요.';
      } else if (failed > 0) {
        message = '$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.';
      }

      _notify();
    } finally {
      if (!_disposed) {
        isDeletingSelected = false;
        _notify();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
