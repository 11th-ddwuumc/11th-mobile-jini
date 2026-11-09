import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'provider/discover_provider.dart';
import 'provider/popular_movie_provider.dart';
import 'router/app_router.dart';

import 'core/network/movie_log_client.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/rating_api_service.dart';
import 'service/tmdb_movie_service.dart';

import 'view_models/sign_up_view_model.dart';
import 'view_models/learning_member_session.dart';

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
        // 영화 관련 Provider
        ChangeNotifierProvider(create: (_) => PopularMovieProvider()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),

        Provider<TmdbMovieService>(create: (_) => TmdbMovieService()),

        // 학습용 회원 세션: 반드시 SignUpViewModel보다 위에!
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),

        // 회원가입 서비스
        Provider<SignUpService>(create: (_) => SignUpService(movieLogClient)),

        // 회원가입 ViewModel
        ChangeNotifierProvider(
          create: (context) => SignUpViewModel(
            context.read<SignUpService>(),
            context.read<LearningMemberSession>(),
          ),
        ),

        // 평점 API 서비스
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
