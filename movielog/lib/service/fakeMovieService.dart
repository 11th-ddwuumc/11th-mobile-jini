import '../model/movie.dart';

class FakeMovieService {
  Future<List<Movie>> fetchMovies() async {
    await Future.delayed(const Duration(seconds: 1));

    return movies;
  }
}
