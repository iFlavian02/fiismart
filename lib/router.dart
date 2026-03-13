import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/route_names.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/password_reset_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/progress/presentation/progress_screen.dart';
import 'features/quiz/presentation/quiz_screen.dart';
import 'features/quiz/presentation/results_screen.dart';
import 'features/quiz/presentation/wrong_answer_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/topics/presentation/home_screen.dart';
import 'features/topics/presentation/topic_detail_screen.dart';
import 'features/upload/presentation/upload_screen.dart';

/// Whether the current user is authenticated.
///
/// This is a temporary placeholder flag. It will be replaced by a
/// Riverpod provider that listens to Firebase Auth state in the auth branch.
bool isLoggedIn = false;

/// Routes that unauthenticated users are still allowed to visit.
const Set<String> _publicRoutes = {
  RouteNames.splash,
  RouteNames.login,
  RouteNames.register,
  RouteNames.passwordReset,
};

/// Application-level router configuration.
///
/// All route paths reference [RouteNames] constants — no hard-coded strings.
/// An auth redirect sends unauthenticated users to [RouteNames.login] for
/// every route not listed in [_publicRoutes].
final GoRouter goRouter = GoRouter(
  initialLocation: RouteNames.splash,
  redirect: (BuildContext context, GoRouterState state) {
    final String location = state.uri.path;
    final bool goingToPublicRoute = _publicRoutes.contains(location);

    if (!isLoggedIn && !goingToPublicRoute) {
      return RouteNames.login;
    }

    return null; // no redirect
  },
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.passwordReset,
      builder: (context, state) => const PasswordResetScreen(),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RouteNames.topicDetail,
      builder: (context, state) => const TopicDetailScreen(),
    ),
    GoRoute(
      path: RouteNames.quiz,
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: RouteNames.wrongAnswer,
      builder: (context, state) => const WrongAnswerScreen(),
    ),
    GoRoute(
      path: RouteNames.quizResults,
      builder: (context, state) => const ResultsScreen(),
    ),
    GoRoute(
      path: RouteNames.progress,
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: RouteNames.upload,
      builder: (context, state) => const UploadScreen(),
    ),
  ],
);
