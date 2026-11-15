import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import '../storage/token_storage.dart';

BaseOptions _movieLogOptions() {
  return BaseOptions(
    baseUrl: 'https://workbook.devnoco.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  );
}

// 로그인, 회원가입, 중복 확인 등 공개 요청
Dio createMovieLogClient() {
  return Dio(_movieLogOptions());
}

// 내 정보, 평점 등록·수정·삭제 등 보호 요청
Dio createAuthMovieLogClient(TokenStorage storage) {
  final dio = Dio(_movieLogOptions());

  dio.interceptors.add(AuthInterceptor(storage));

  return dio;
}
