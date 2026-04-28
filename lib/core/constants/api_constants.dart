class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'BFF_BASE_URL',
    defaultValue: 'https://hono.medev-tech.fr',
  );

  static const String pythonServiceUrl = String.fromEnvironment(
    'PYTHON_SERVICE_URL',
    defaultValue: 'https://python.medev-tech.fr',
  );

  // Auth calls vont directement sur l'auth-service (le BFF proxy consomme le body avant de le transférer)
  static const String authBaseUrl = String.fromEnvironment(
    'AUTH_SERVICE_URL',
    defaultValue: 'https://hono.medev-tech.fr',
  );

  static const String signIn = '/api/auth/sign-in/email';
  static const String signUp = '/api/auth/sign-up/email';
  static const String uploadMeal = '/api/nutrition/upload';
  static const String analyzeMeal = '/api/nutrition/analyze';
  static const String generateMenu = '/api/generate-menu';
  static const String weeklyPlan = '/api/coach/plan';
  static const String userProfile = '/api/user/profile';
  static const String dailyStats = '/api/user/today';
  static const String nutritionHistory = '/api/nutrition/history';
}
