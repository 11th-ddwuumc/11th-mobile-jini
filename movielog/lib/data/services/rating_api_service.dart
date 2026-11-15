import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

RatingDto parseRatingResult(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw StateError('평점 응답 형식이 올바르지 않습니다.');
  }

  final common = CommonResponse<RatingDto>.fromJson(
    data,
    (value) => RatingDto.fromJson(value as Map<String, dynamic>),
  );

  final rating = common.result;

  if (rating == null) {
    throw StateError('평점 result가 없습니다.');
  }

  return rating;
}

List<RatingDto> parseRatingList(Object? data) {
  if (data is! List) {
    throw StateError('평점 목록 응답은 배열이어야 합니다.');
  }

  return data
      .map((value) => RatingDto.fromJson(value as Map<String, dynamic>))
      .toList();
}

class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);

  final Dio _publicDio;
  final Dio _authDio;

  // 내 평점 목록 조회: 공개 API
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _publicDio.get('/v7/members/$memberId/ratings');

    return parseRatingList(response.data);
  }

  // 평점 등록: 보호 API
  Future<RatingDto> createRating({required CreateRatingRequest request}) async {
    final response = await _authDio.post('/v7/ratings', data: request.toJson());

    return parseRatingResult(response.data);
  }

  // 평점 수정: 보호 API
  // PATCH는 전체 교체이므로 score와 comment를 항상 함께 전달
  Future<RatingDto> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final response = await _authDio.patch(
      '/v7/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );

    return parseRatingResult(response.data);
  }

  // 평점 삭제: 보호 API
  // v7 삭제 성공은 HTTP 200, result는 null
  Future<void> deleteRating(int ratingId) async {
    final response = await _authDio.delete('/v7/ratings/$ratingId');

    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

// 내 평점 목록 오류 메시지
String writeMyRatingsErrorMessage(DioException error) {
  return writeErrorMessage(error);
}

// 공통 오류 메시지
String writeErrorMessage(DioException error) {
  final status = error.response?.statusCode;
  final data = error.response?.data;

  final serverMessage = data is Map ? data['message']?.toString() : null;

  if (serverMessage != null && serverMessage.isNotEmpty) {
    return serverMessage;
  }

  final code = data is Map ? data['code']?.toString() : null;

  switch (code) {
    case 'AUTH401_2':
    case 'AUTH401_3':
    case 'AUTH401_4':
      return '로그인이 만료됐어요. 다시 로그인해 주세요.';
    case 'RATING403_1':
      return '본인이 등록한 평점만 수정하거나 삭제할 수 있습니다.';
    case 'RATING404_1':
      return '평점을 찾을 수 없습니다. 목록을 새로고침해 주세요.';
    case 'RATING409_1':
      return '이미 해당 영화에 평점을 등록했습니다.';
    case 'COMMON400':
      return '입력 내용을 확인해 주세요.';
  }

  switch (status) {
    case 400:
      return '잘못된 요청입니다. 입력 내용을 확인해 주세요.';
    case 401:
      return '로그인이 필요합니다.';
    case 403:
      return '요청 권한이 없습니다.';
    case 404:
      return '평점을 찾을 수 없습니다.';
    case 409:
      return '이미 처리되었거나 요청 상태가 충돌했습니다.';
    default:
      return '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
  }
}

// 목록 재조회가 필요한 오류인지 확인
bool shouldRefreshAfterRatingError(DioException error) {
  final data = error.response?.data;
  final code = data is Map ? data['code']?.toString() : null;

  return code == 'RATING403_1' ||
      code == 'RATING404_1' ||
      error.response?.statusCode == 403 ||
      error.response?.statusCode == 404;
}
