import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/services/rating_api_service.dart';
import '../../service/tmdb_movie_service.dart';
import '../../model/tmdb_movie_dto.dart';
import '../data/models/rating_with_movie.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._movieService, this.memberId);

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

    isUpdating = true;
    refreshWarning = null;
    message = null;
    _notify();

    try {
      await _service.updateRating(
        memberId: memberId,
        ratingId: ratingId,
        score: score,
        comment: comment,
      );

      if (_disposed) return;

      await _refreshAfterWrite();
    } on DioException catch (error) {
      if (!_disposed) {
        message = writeErrorMessage(error);
        _notify();

        if (shouldRefreshAfterRatingError(error)) {
          await load();
        }
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

    deletingRatingIds.add(ratingId);
    refreshWarning = null;
    message = null;
    _notify();

    try {
      await _service.deleteRating(memberId: memberId, ratingId: ratingId);

      selectedRatingIds.remove(ratingId);

      if (_disposed) return;

      await _refreshAfterWrite();
    } on DioException catch (error) {
      if (!_disposed) {
        message = writeErrorMessage(error);
        _notify();

        if (shouldRefreshAfterRatingError(error)) {
          await load();
        }
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

    isDeletingSelected = true;
    refreshWarning = null;
    message = null;
    _notify();

    var failed = 0;
    final idsToDelete = selectedRatingIds.toList();

    try {
      for (final ratingId in idsToDelete) {
        if (_disposed) return;

        try {
          await _service.deleteRating(memberId: memberId, ratingId: ratingId);

          selectedRatingIds.remove(ratingId);
        } catch (_) {
          failed++;
        }
      }

      if (_disposed) return;

      await _refreshAfterWrite();

      if (_disposed) return;

      if (failed > 0) {
        message = '$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.';
        _notify();
      }
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
