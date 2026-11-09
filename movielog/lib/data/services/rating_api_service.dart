import 'package:dio/dio.dart';

import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._dio);
  final Dio _dio;

  // 내 평점 목록 조회
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/v5/members/$memberId/ratings');
    final list = response.data as List<dynamic>;

    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // 평점 등록
  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    final response = await _dio.post(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );

    if (response.statusCode != 201) {
      throw StateError('예상하지 못한 등록 응답: ${response.statusCode}');
    }
  }

  // 평점 수정
  Future<void> updateRating({
    required int memberId,
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: {
        'score': score,
        'comment': comment == null || comment.trim().isEmpty
            ? null
            : comment.trim(),
      },
    );
  }

  // 평점 삭제
  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    await _dio.delete('/v6/members/$memberId/ratings/$ratingId');
  }
}

// 내 평점 목록 및 공통 오류 메시지
String writeMyRatingsErrorMessage(DioException error) {
  return writeErrorMessage(error);
}

// 공통 오류 메시지
String writeErrorMessage(DioException error) {
  final status = error.response?.statusCode;
  final data = error.response?.data;

  // 서버에서 전달한 메시지가 있으면 우선 사용
  final serverMessage = data is Map ? data['message']?.toString() : null;

  if (serverMessage != null && serverMessage.isNotEmpty) {
    return serverMessage;
  }

  switch (status) {
    case 400:
      return '잘못된 요청입니다. 입력 내용을 확인해 주세요.';
    case 403:
      return '요청 권한이 없습니다.';
    case 404:
      return '회원 또는 평점을 찾을 수 없습니다.';
    case 409:
      return '이미 처리되었거나 요청 상태가 충돌했습니다.';
    default:
      return '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
  }
}

// 403·404 오류 발생 시 목록 재조회 여부
bool shouldRefreshAfterRatingError(DioException error) {
  final status = error.response?.statusCode;
  final data = error.response?.data;
  final code = data is Map ? data['code']?.toString() : null;

  return status == 403 ||
      status == 404 ||
      code == 'COMMON403' ||
      code == 'COMMON404';
}
