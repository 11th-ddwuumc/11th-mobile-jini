import 'package:flutter/material.dart';

import 'provider/discover_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'router/app_router.dart';

import 'package:provider/provider.dart';

import 'provider/popular_movie_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  if (dotenv.env['TMDB_ACCESS_TOKEN']?.isNotEmpty != true) {
    throw StateError('TMDB_ACCESS_TOKEN이 .env에 설정되지 않았습니다.');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PopularMovieProvider()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),
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
