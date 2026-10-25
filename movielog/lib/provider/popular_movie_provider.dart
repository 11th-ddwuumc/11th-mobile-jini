import 'package:flutter/foundation.dart';

import '../model/tmdb_movie_dto.dart';
import '../service/tmdb_movie_service.dart';

class PopularMovieProvider extends ChangeNotifier {
  PopularMovieProvider({TmdbMovieService? service})
    : _service = service ?? TmdbMovieService();

  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = [];

  bool isLoading = false;
  bool hasError = false;
  bool _hasLoaded = false;

  Future<void> loadPopular() async {
    // 이미 성공했거나 요청 중이면 중복 호출하지 않는다.
    if (_hasLoaded || isLoading) return;

    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final result = await _service.fetchPopular();

      // 응답이 5개 미만이어도 안전하게 처리한다.
      movies = result.results.take(5).toList();
      _hasLoaded = true;
    } catch (_) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (isLoading) return;

    _hasLoaded = false;
    await loadPopular();
  }
}
