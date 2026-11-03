import 'package:flutter/foundation.dart';

import '../model/tmdb_genre_dto.dart';
import '../model/tmdb_movie_dto.dart';
import '../service/tmdb_movie_service.dart';

class DiscoverProvider extends ChangeNotifier {
  DiscoverProvider({TmdbMovieService? service})
    : _service = service ?? TmdbMovieService();

  final TmdbMovieService _service;

  List<TmdbGenreDto> genres = [];
  List<TmdbMovieDto> movies = [];

  int? selectedGenreId;

  bool isLoading = false;
  bool hasError = false;
  bool isInitialized = false;

  Future<void> loadInitial() async {
    if (isInitialized || isLoading) return;

    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      genres = await _service.fetchGenres();
      await _fetchMovies();
      isInitialized = true;
    } catch (_) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectGenre(int? genreId) async {
    if (isLoading || selectedGenreId == genreId) return;

    selectedGenreId = genreId;
    movies = [];
    hasError = false;
    isLoading = true;
    notifyListeners();

    try {
      await _fetchMovies();
    } catch (_) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (isLoading) return;

    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      if (genres.isEmpty) {
        genres = await _service.fetchGenres();
      }

      await _fetchMovies();
      isInitialized = true;
    } catch (_) {
      hasError = true;
      movies = [];
    }
  }

  Future<void> _fetchMovies() async {
    final uniqueMovies = <int, TmdbMovieDto>{};
    var page = 1;
    var totalPages = 1;

    while (uniqueMovies.length < 30 && page <= totalPages) {
      final result = await _service.fetchDiscover(
        page: page,
        genreId: selectedGenreId,
      );

      totalPages = result.totalPages;

      for (final movie in result.results) {
        uniqueMovies.putIfAbsent(movie.id, () => movie);

        if (uniqueMovies.length >= 30) break;
      }

      if (result.results.isEmpty) break;

      page++;
    }

    movies = uniqueMovies.values.toList();
  }
}
