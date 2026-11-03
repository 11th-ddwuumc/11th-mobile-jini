import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'provider/discover_provider.dart';
import 'provider/popular_movie_provider.dart';
import 'router/app_router.dart';

import 'core/network/movie_log_client.dart';
import 'data/services/member_check_service.dart';
import 'data/services/rating_api_service.dart';
import '../service/tmdb_movie_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  if (dotenv.env['TMDB_ACCESS_TOKEN']?.isNotEmpty != true) {
    throw StateError('TMDB_ACCESS_TOKEN이 .env에 설정되지 않았습니다.');
  }

  final movieLogClient = createMovieLogClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PopularMovieProvider()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),

        Provider<TmdbMovieService>(create: (_) => TmdbMovieService()),
        Provider<MemberCheckService>(
          create: (_) => MemberCheckService(movieLogClient),
        ),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),
      ],
      child: const MovieLogApp(),
    ),
  );
}

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
