class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'BFF_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String uploadMeal = '/api/nutrition/analyze';
  static const String weeklyPlan = '/api/coach/plan';
  static const String userProfile = '/api/user/profile';
}
