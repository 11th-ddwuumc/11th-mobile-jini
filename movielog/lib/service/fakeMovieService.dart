import '../model/movie.dart';

class FakeMovieService {
  FakeMovieService({this.returnEmpty = false, this.returnError = false});

  final bool returnEmpty;
  final bool returnError;

  Future<List<Movie>> fetchMovies() async {
    await Future.delayed(const Duration(seconds: 1));

    if (returnError) {
      throw Exception('영화 목록을 불러오지 못했습니다.');
    }

    if (returnEmpty) {
      return [];
    }

    return movies;
  }
}
