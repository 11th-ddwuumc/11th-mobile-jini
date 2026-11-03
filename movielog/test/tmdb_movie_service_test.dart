import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/service/tmdb_movie_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  test('TMDB 인기 영화 API 호출 확인', () async {
    final service = TmdbMovieService();
    final result = await service.fetchPopular();

    expect(result.page, 1);
    expect(result.results, isNotEmpty);
    expect(result.results.length, greaterThanOrEqualTo(1));
  });
}
