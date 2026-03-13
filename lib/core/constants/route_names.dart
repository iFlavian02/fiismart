/// Centralised route path constants used by [GoRouter] in `router.dart`.
///
/// Every screen in the app must reference these constants instead of
/// hard-coding path strings — per steering.md conventions.
class RouteNames {
  RouteNames._(); // prevent instantiation

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String passwordReset = '/password-reset';
  static const String home = '/home';
  static const String topicDetail = '/topic-detail';
  static const String quiz = '/quiz';
  static const String wrongAnswer = '/wrong-answer';
  static const String quizResults = '/quiz-results';
  static const String progress = '/progress';
  static const String upload = '/upload';
}
