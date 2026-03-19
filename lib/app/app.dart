import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import '../features/nutrition/presentation/screens/camera_screen.dart';
import '../features/nutrition/presentation/screens/meal_result_screen.dart';
import '../features/coach/presentation/screens/rpe_screen.dart';
import '../features/coach/presentation/screens/session_screen.dart';
import '../features/offline/domain/entities/day_plan.dart';
import '../features/offline/presentation/screens/week_plan_screen.dart';
import '../shared/screens/dev_home_screen.dart';

class HealthAIApp extends StatelessWidget {
  const HealthAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HealthAI Coach',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DevHomeScreen(),
    ),
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: '/meal-result',
      builder: (context, state) {
        final imagePath = state.extra as String;
        return MealResultScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/week-plan',
      builder: (context, state) => const WeekPlanScreen(),
    ),
    GoRoute(
      path: '/session',
      builder: (context, state) {
        final dayPlan = state.extra as DayPlan;
        return SessionScreen(dayPlan: dayPlan);
      },
    ),
    GoRoute(
      path: '/rpe',
      builder: (context, state) => const RpeScreen(),
    ),
  ],
);
