import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import '../core/auth/token_storage.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/feed/domain/entities/post.dart';
import '../features/feed/presentation/screens/comments_screen.dart';
import '../features/feed/presentation/screens/create_post_screen.dart';
import '../features/nutrition/presentation/screens/camera_screen.dart';
import '../features/nutrition/presentation/screens/manual_meal_entry_screen.dart';
import '../features/nutrition/presentation/screens/meal_result_screen.dart';
import '../features/coach/presentation/screens/rpe_screen.dart';
import '../features/coach/presentation/screens/session_screen.dart';
import '../features/offline/domain/entities/day_plan.dart';
import '../features/offline/presentation/screens/week_plan_screen.dart';
import '../features/meal_plan/presentation/screens/meal_plan_screen.dart';
import '../shared/screens/home_screen.dart';
import '../shared/screens/splash_screen.dart';

class HealthAIApp extends StatelessWidget {
  const HealthAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HealthAI Coach',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

Page<T> _fadePage<T>(Widget child, GoRouterState state) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );

Page<T> _slidePage<T>(Widget child, GoRouterState state) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );

final _router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final loc = state.matchedLocation;
    if (loc == '/splash') return null;
    final token = TokenStorage.cachedToken;
    final publicRoutes = ['/login', '/signup'];
    if (token == null && !publicRoutes.contains(loc)) return '/login';
    if (token != null && publicRoutes.contains(loc)) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (c, s) => _fadePage(const SplashScreen(), s),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) => _fadePage(const LoginScreen(), s),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (c, s) => _slidePage(const SignupScreen(), s),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (c, s) => _fadePage(const HomeScreen(), s),
    ),
    GoRoute(
      path: '/camera',
      pageBuilder: (c, s) => _slidePage(const CameraScreen(), s),
    ),
    GoRoute(
      path: '/meal-result',
      pageBuilder: (c, s) {
        final imagePath = s.extra as String;
        return _slidePage(MealResultScreen(imagePath: imagePath), s);
      },
    ),
    GoRoute(
      path: '/manual-meal',
      pageBuilder: (c, s) => _slidePage(const ManualMealEntryScreen(), s),
    ),
    GoRoute(
      path: '/week-plan',
      pageBuilder: (c, s) => _slidePage(const WeekPlanScreen(), s),
    ),
    GoRoute(
      path: '/session',
      pageBuilder: (c, s) {
        final dayPlan = s.extra as DayPlan;
        return _slidePage(SessionScreen(dayPlan: dayPlan), s);
      },
    ),
    GoRoute(
      path: '/rpe',
      pageBuilder: (c, s) => _slidePage(const RpeScreen(), s),
    ),
    GoRoute(
      path: '/meal-plan',
      pageBuilder: (c, s) => _slidePage(const MealPlanScreen(), s),
    ),
    GoRoute(
      path: '/create-post',
      pageBuilder: (c, s) => _slidePage(const CreatePostScreen(), s),
    ),
    GoRoute(
      path: '/comments',
      pageBuilder: (c, s) {
        final post = s.extra as Post;
        return _slidePage(CommentsScreen(post: post), s);
      },
    ),
  ],
);
