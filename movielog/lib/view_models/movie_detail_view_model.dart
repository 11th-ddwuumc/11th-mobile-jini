import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/services/rating_api_service.dart';
import '../data/models/rating_request.dart';
import '../model/tmdb_movie_dto.dart';
import 'sign_up_view_model.dart';

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratingService, this.memberId, this.movie);

  final RatingApiService _ratingService;
  final int? memberId;
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;

  bool _disposed = false;

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  Future<void> createRating({required int score, String? comment}) async {
    if (_disposed || isSubmitting) return;

    final id = memberId;

    if (id == null) {
      submitStatus = SubmitStatus.error;
      submitMessage = '먼저 회원가입을 완료해 주세요.';
      _notify();
      return;
    }

    if (score < 1 || score > 5) {
      submitStatus = SubmitStatus.error;
      submitMessage = '별점을 선택해 주세요.';
      _notify();
      return;
    }

    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    _notify();

    try {
      await _ratingService.createRating(
        memberId: id,
        request: CreateRatingRequest(
          movieId: movie.id,
          score: score,
          comment: comment,
        ),
      );

      if (_disposed) return;

      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;

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
