import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../startScreen.dart';
import '../signupScreen.dart';
import '../homeScreen.dart';
import '../mainScreen.dart';
import '../movieListScreen.dart';
import '../profileScreen.dart';
import '../model/tmdb_movie_dto.dart';

import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/movie_detail_loader.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/edit_profile_screen.dart';

import '../view_models/auth_view_model.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/edit_profile_view_model.dart';

import '../data/services/rating_api_service.dart';
import '../data/services/member_api_service.dart';

import '../service/tmdb_movie_service.dart';

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter create(AuthViewModel authViewModel) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/start',
      refreshListenable: authViewModel,

      redirect: (context, state) {
        return authRedirect(authViewModel.status, state.matchedLocation);
      },

      routes: [
        GoRoute(
          path: '/start',
          builder: (context, state) {
            return AnimatedBuilder(
              animation: authViewModel,
              builder: (context, child) {
                return SplashScreen(
                  message: authViewModel.message,
                  onRetry: authViewModel.status == AuthStatus.retryRequired
                      ? authViewModel.restoreSession
                      : null,
                );
              },
            );
          },
        ),

        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

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
                // 7번: 프로필 수정
                GoRoute(
                  path: 'profile/edit',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final auth = context.watch<AuthViewModel>();

                    if (auth.member == null) {
                      return Scaffold(
                        appBar: AppBar(
                          centerTitle: true,
                          title: const Text('프로필 수정'),
                        ),
                        body: Center(
                          child: auth.memberStatus == MemberLoadStatus.error
                              ? ElevatedButton(
                                  onPressed: () {
                                    auth.loadMember(force: true);
                                  },
                                  child: const Text('다시 시도'),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      );
                    }

                    return ChangeNotifierProvider<EditProfileViewModel>(
                      create: (context) => EditProfileViewModel(
                        context.read<MemberApiService>(),
                        auth,
                      ),
                      child: const EditProfileScreen(),
                    );
                  },
                ),

                // 기존 내가 등록한 평점
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
                        context.read<AuthViewModel>(),
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
}

String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/signup'};

  final atStart = location == '/start' || location == '/splash';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    AuthStatus.initializing ||
    AuthStatus.retryRequired => atStart ? null : '/start',

    AuthStatus.signedOut ||
    AuthStatus.authenticating => atPublic ? null : '/login',

    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}
