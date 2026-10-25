import 'package:go_router/go_router.dart';

import '../startScreen.dart';
import '../signupScreen.dart';
import '../homeScreen.dart';
import '../mainScreen.dart';
import '../movieListScreen.dart';
import '../movieDetailScreen.dart';
import '../profileScreen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/home',
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
          ),
        ],
      ),
    ],
  );
}
