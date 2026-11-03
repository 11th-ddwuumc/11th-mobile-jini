import 'package:go_router/go_router.dart';

import '../startScreen.dart';
import '../signupScreen.dart';
import '../homeScreen.dart';
import '../mainScreen.dart';
import '../movieListScreen.dart';
import '../movieDetailScreen.dart';
import '../profileScreen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/my_ratings_view_model.dart';
import '../data/services/rating_api_service.dart';
import '../service/tmdb_movie_service.dart';
import '../profileScreen.dart';
import '../screens/my_ratings_screen.dart';

class AppRouter {
  AppRouter._();

  // ① root Navigator를 가리키는 키
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  // ② GoRouter에 root Navigator 등록
  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/start',
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
                  final movieId = int.tryParse(
                    state.pathParameters['movieId'] ?? '',
                  );

                  return MovieDetailScreen(movieId: movieId);
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
                  return ChangeNotifierProvider(
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      sampleMemberId,
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
