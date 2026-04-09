import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../features/nutrition/presentation/screens/nutrition_hub_screen.dart';
import '../../features/coach/presentation/screens/coach_hub_screen.dart';
import '../../features/meal_plan/presentation/screens/meal_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _screens = [
    NutritionHubScreen(),
    CoachHubScreen(),
    MealPlanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 0.5),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1) {
                context.push('/camera');
                return;
              }
              // index 0→screen 0, 1→camera (handled), 2→screen 1, 3→screen 2
              setState(() => _currentIndex = index > 1 ? index - 1 : index);
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_outlined),
                activeIcon: Icon(Icons.restaurant),
                label: 'Nutrition',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColors.textOnPrimary, size: 20),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_outlined),
                activeIcon: Icon(Icons.fitness_center),
                label: 'Coach',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu_outlined),
                activeIcon: Icon(Icons.restaurant_menu),
                label: 'Menu IA',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
