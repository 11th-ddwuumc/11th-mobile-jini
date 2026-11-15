import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/services/rating_api_service.dart';
import '../data/models/rating_request.dart';
import '../model/tmdb_movie_dto.dart';
import 'sign_up_view_model.dart';
import 'auth_view_model.dart';
import '../data/models/rating_dto.dart';

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._authViewModel,
    this.memberId,
    this.movie,
  );

  final RatingApiService _ratingService;
  final AuthViewModel _authViewModel;
  final int? memberId;
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  RatingDto? createdRating;

  bool _disposed = false;

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  Future<void> createRating({required int score, String? comment}) async {
    if (_disposed || isSubmitting) return;

    final id = memberId;

    if (_authViewModel.status != AuthStatus.signedIn) {
      submitStatus = SubmitStatus.error;
      submitMessage = '로그인이 필요합니다.';
      _notify();
      return;
    }

    if (score < 1 || score > 5) {
      submitStatus = SubmitStatus.error;
      submitMessage = '별점을 선택해 주세요.';
      _notify();
      return;
    }

    final sessionVersion = _authViewModel.sessionVersion;

    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    createdRating = null;
    _notify();

    try {
      final result = await _ratingService.createRating(
        request: CreateRatingRequest(
          movieId: movie.id,
          score: score,
          comment: comment,
        ),
      );

      if (_disposed || sessionVersion != _authViewModel.sessionVersion) {
        return;
      }

      createdRating = result;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed || sessionVersion != _authViewModel.sessionVersion) {
        return;
      }

      final data = error.response?.data;
      final code = data is Map ? data['code']?.toString() : null;

      if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
        await _authViewModel.expireSession();

        if (_disposed) return;
      }

      submitStatus = SubmitStatus.error;
      submitMessage = writeErrorMessage(error);
    } catch (_) {
      if (_disposed) return;

      submitStatus = SubmitStatus.error;
      submitMessage = '평점 등록에 실패했습니다. 잠시 후 다시 시도해 주세요.';
    }

    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
