import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../startScreen.dart';
import '../signupScreen.dart';
import '../homeScreen.dart';
import '../mainScreen.dart';
import '../movieListScreen.dart';
import '../screens/movie_detail_loader.dart';
import '../profileScreen.dart';
import '../model/tmdb_movie_dto.dart';

import '../view_models/my_ratings_view_model.dart';
import '../view_models/learning_member_session.dart';

import '../data/services/rating_api_service.dart';
import '../service/tmdb_movie_service.dart';

import '../screens/my_ratings_screen.dart';

class AppRouter {
  AppRouter._();

  // ① root Navigator를 가리키는 키
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  // ② GoRouter에 root Navigator 등록
  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/signup',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),

          GoRoute(
            path: '/movies',
            builder: (context, state) => const MovieListScreen(),
            routes: [
              GoRoute(
                path: ':movieId',
                builder: (context, state) {
                  final id = int.tryParse(
                    state.pathParameters['movieId'] ?? '',
                  );
                  if (id == null || id < 1) {
                    return const Scaffold(
                      body: Center(child: Text('영화 ID가 올바르지 않습니다.')),
                    );
                  }
                  final extra = state.extra;
                  return MovieDetailLoader(
                    movieId: id,
                    initialMovie: extra is TmdbMovieDto && extra.id == id
                        ? extra
                        : null,
                  );
                },
              ),
            ],
          ),

          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'ratings',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = context.read<LearningMemberSession>().memberId;

                  if (id == null) {
                    return Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        title: const Text('내가 등록한 평점'),
                      ),
                      body: const Center(child: Text('학습용 회원가입이 필요합니다.')),
                    );
                  }

                  return ChangeNotifierProvider<MyRatingsViewModel>(
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      id,
                    )..load(),
                    child: const MyRatingsScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
