class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'BFF_BASE_URL',
    defaultValue: 'http://localhost:3002',
  );

  static const String signIn = '/api/auth/sign-in/email';
  static const String signUp = '/api/auth/sign-up/email';
  static const String uploadMeal = '/api/nutrition/upload';
  static const String weeklyPlan = '/api/coach/plan';
  static const String userProfile = '/api/user/profile';
}
