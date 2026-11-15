import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'provider/discover_provider.dart';
import 'provider/popular_movie_provider.dart';
import 'router/app_router.dart';

import 'core/network/movie_log_client.dart';
import 'core/storage/token_storage.dart';

import 'data/services/sign_up_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/member_api_service.dart';

import 'service/tmdb_movie_service.dart';

import 'view_models/sign_up_view_model.dart';
import 'view_models/learning_member_session.dart';
import 'view_models/auth_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  if (dotenv.env['TMDB_ACCESS_TOKEN']?.isNotEmpty != true) {
    throw StateError('TMDB_ACCESS_TOKEN이 .env에 설정되지 않았습니다.');
  }

  // 보안 토큰 저장소
  final tokenStorage = SecureTokenStorage(const FlutterSecureStorage());

  // 공개용 / 보호용 MovieLog Client
  final publicClient = createMovieLogClient();
  final authClient = createAuthMovieLogClient(tokenStorage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PopularMovieProvider()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),

        Provider<TmdbMovieService>(create: (_) => TmdbMovieService()),

        Provider<TokenStorage>.value(value: tokenStorage),

        // 공개 Client 사용
        Provider<SignUpService>(create: (_) => SignUpService(publicClient)),
        Provider<AuthApiService>(create: (_) => AuthApiService(publicClient)),

        // 보호 Client 사용
        Provider<MemberApiService>(create: (_) => MemberApiService(authClient)),

        // 기존 학습용 회원 세션
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),

        ChangeNotifierProvider(
          create: (context) => SignUpViewModel(
            context.read<SignUpService>(),
            context.read<LearningMemberSession>(),
          ),
        ),

        // 기존 평점 서비스는 현재 구현을 유지
        Provider<RatingApiService>(
          create: (_) => RatingApiService(publicClient, authClient),
        ),

        // 인증 ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthApiService>(),
            context.read<MemberApiService>(),
            context.read<TokenStorage>(),
          ),
        ),
      ],
      child: const MovieLogRouterApp(),
    ),
  );
}

class MovieLogRouterApp extends StatefulWidget {
  const MovieLogRouterApp({super.key});

  @override
  State<MovieLogRouterApp> createState() => _MovieLogRouterAppState();
}

class _MovieLogRouterAppState extends State<MovieLogRouterApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    final authViewModel = context.read<AuthViewModel>();

    _router = AppRouter.create(authViewModel);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        authViewModel.restoreSession();
      }
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      routerConfig: _router,
    );
  }
}
