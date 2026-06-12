import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../features/coach/presentation/screens/coach_hub_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/meal_plan/presentation/screens/meal_plan_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_hub_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

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
    FeedScreen(),
    ProfileScreen(),
  ];

  static const _navItems = [
    (Icons.restaurant_outlined, Icons.restaurant_rounded, 'Nutrition'),
    (Icons.fitness_center_outlined, Icons.fitness_center_rounded, 'Coach'),
    (Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'Menu IA'),
    (Icons.people_outline, Icons.people_rounded, 'Communauté'),
    (Icons.person_outline, Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // Items 0-1 (Nutrition, Coach)
              ...[0, 1].map((i) => _NavItem(
                    icon: _navItems[i].$1,
                    activeIcon: _navItems[i].$2,
                    label: _navItems[i].$3,
                    isSelected: _currentIndex == i,
                    onTap: () => setState(() => _currentIndex = i),
                  )),
              // FAB central gradient
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.push('/camera'),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppGradients.nutrition,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4005966A),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
              // Items 2-4 (Menu IA, Communauté, Profil)
              ...[2, 3, 4].map((i) => _NavItem(
                    icon: _navItems[i].$1,
                    activeIcon: _navItems[i].$2,
                    label: _navItems[i].$3,
                    isSelected: _currentIndex == i,
                    onTap: () => setState(() => _currentIndex = i),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
