import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TmdbLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[TMDB] Request: ${options.method} ${options.path}');

    // 인증 헤더의 실제 값은 절대 로그에 출력하지 않는다.
    final safeHeaders = Map<String, dynamic>.from(options.headers);
    if (safeHeaders.containsKey('Authorization')) {
      safeHeaders['Authorization'] = '[REDACTED]';
    }

    debugPrint('[TMDB] Headers: $safeHeaders');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[TMDB] Response: ${response.statusCode} ${response.requestOptions.path}',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[TMDB] Error: ${err.response?.statusCode ?? 'Network error'} '
      '${err.requestOptions.path}',
    );

    handler.next(err);
  }
}
