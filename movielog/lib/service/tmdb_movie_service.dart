import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/tmdb_genre_dto.dart';
import '../model/tmdb_movie_dto.dart';
import 'tmdb_logging_interceptor.dart';
import '../model/tmdb_movie_detail_dto.dart';

class TmdbMovieService {
  TmdbMovieService({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    final token = dotenv.env['TMDB_ACCESS_TOKEN'];

    if (token == null || token.isEmpty) {
      throw StateError('TMDB_ACCESS_TOKEN이 설정되지 않았습니다.');
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(TmdbLoggingInterceptor());

    return dio;
  }

  // 인기 영화 조회
  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    final response = await _dio.get(
      '/movie/popular',
      queryParameters: {'language': 'ko-KR', 'page': page},
    );

    return TmdbMoviePageDto.fromJson(response.data as Map<String, dynamic>);
  }

  // 영화 장르 목록 조회
  Future<List<TmdbGenreDto>> fetchGenres() async {
    final response = await _dio.get(
      '/genre/movie/list',
      queryParameters: {'language': 'ko-KR'},
    );

    final data = response.data as Map<String, dynamic>;
    final genres = data['genres'] as List<dynamic>? ?? [];

    return genres
        .map((genre) => TmdbGenreDto.fromJson(genre as Map<String, dynamic>))
        .toList();
  }

  // Discover 영화 조회
  // genreId가 null이면 전체 영화 조회
  Future<TmdbMoviePageDto> fetchDiscover({int page = 1, int? genreId}) async {
    final queryParameters = <String, dynamic>{
      'language': 'ko-KR',
      'page': page,
      'sort_by': 'popularity.desc',
    };

    // 전체 선택이면 with_genres를 요청에 넣지 않는다.
    if (genreId != null) {
      queryParameters['with_genres'] = genreId;
    }

    final response = await _dio.get(
      '/discover/movie',
      queryParameters: queryParameters,
    );

    return TmdbMoviePageDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TmdbMovieDetailDto> fetchMovieDetails(int movieId) async {
    final response = await _dio.get(
      '/movie/$movieId',
      queryParameters: {'language': 'ko-KR'},
    );

    return TmdbMovieDetailDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TmdbMovieDto> fetchMovieDetail(int movieId) async {
    final response = await _dio.get(
      '/movie/$movieId',
      queryParameters: {'language': 'ko-KR'},
    );

    return TmdbMovieDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TmdbMovieDto?> findMovieById(int movieId) async {
    try {
      return await fetchMovieDetail(movieId);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }
}
