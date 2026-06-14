import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../domain/entities/daily_stats.dart';
import '../../domain/entities/meal_history_item.dart';
import '../providers/nutrition_provider.dart';

class NutritionHubScreen extends ConsumerWidget {
  const NutritionHubScreen({super.key});

  static const double _calorieTarget = 2200;
  static const double _proteinTarget = 150;
  static const double _carbsTarget = 280;
  static const double _fatTarget = 73;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(nutritionDailyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: dailyAsync.when(
              data: (daily) => _GradientHero(stats: daily.stats, calorieTarget: _calorieTarget),
              loading: () => _GradientHero(stats: DailyStats.empty, calorieTarget: _calorieTarget),
              error: (_, __) => _GradientHero(stats: DailyStats.empty, calorieTarget: _calorieTarget),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                dailyAsync.when(
                  data: (daily) => _AnimatedMacroGrid(
                    stats: daily.stats,
                    proteinTarget: _proteinTarget,
                    carbsTarget: _carbsTarget,
                    fatTarget: _fatTarget,
                  ),
                  loading: () => const _MacroGridShimmer(),
                  error: (_, __) => _AnimatedMacroGrid(
                    stats: DailyStats.empty,
                    proteinTarget: _proteinTarget,
                    carbsTarget: _carbsTarget,
                    fatTarget: _fatTarget,
                  ),
                ),
                const SizedBox(height: 24),
                _buildAnalyzeSection(context),
                const SizedBox(height: 24),
                dailyAsync.when(
                  data: (daily) => _buildRecentMeals(daily.history),
                  loading: () => Column(
                    children: List.generate(3, (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: ShimmerCard(),
                    )),
                  ),
                  error: (_, __) => _buildRecentMeals([]),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ANALYSER UN REPAS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textTertiary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _GradientButton(label: 'Photo', icon: Icons.camera_alt_rounded, gradient: AppGradients.nutrition, onTap: () => context.push('/camera'))),
            const SizedBox(width: 10),
            Expanded(child: _GradientButton(label: 'Galerie', icon: Icons.photo_library_rounded, gradient: AppGradients.menu, onTap: () => _pickFromGallery(context))),
          ],
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => context.push('/manual-meal'),
          icon: const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.primary),
          label: const Text(
            'Saisir un repas manuellement',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && context.mounted) {
      final compressed = await ImageUtils.compress(picked.path);
      if (context.mounted) context.push('/meal-result', extra: compressed);
    }
  }

  Widget _buildRecentMeals(List<MealHistoryItem> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DERNIERS REPAS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textTertiary)),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.card,
            child: const Center(child: Text('Aucun repas enregistré aujourd\'hui', style: TextStyle(fontSize: 13, color: AppColors.textTertiary))),
          )
        else
          Container(
            decoration: AppDecorations.card,
            child: Column(
              children: history.take(5).toList().asMap().entries.map((entry) {
                final i = entry.key;
                return Column(children: [
                  if (i > 0) const Divider(height: 0.5, indent: 56),
                  _MealRow(item: entry.value),
                ]);
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// ─── Hero gradient avec compteur animé ──────────────────────────────────────

class _GradientHero extends StatefulWidget {
  final DailyStats stats;
  final double calorieTarget;
  const _GradientHero({required this.stats, required this.calorieTarget});

  @override
  State<_GradientHero> createState() => _GradientHeroState();
}

class _GradientHeroState extends State<_GradientHero> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _counterAnim;
  late Animation<double> _progressAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    final ratio = widget.calorieTarget > 0
        ? (widget.stats.calories / widget.calorieTarget).clamp(0.0, 1.0)
        : 0.0;
    _counterAnim = Tween<double>(begin: 0, end: widget.stats.calories)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _progressAnim = Tween<double>(begin: 0, end: ratio)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)));
    Future.delayed(const Duration(milliseconds: 100), () { if (mounted) _controller.forward(); });
  }

  @override
  void didUpdateWidget(covariant _GradientHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats.calories != widget.stats.calories ||
        oldWidget.calorieTarget != widget.calorieTarget) {
      final ratio = widget.calorieTarget > 0
          ? (widget.stats.calories / widget.calorieTarget).clamp(0.0, 1.0)
          : 0.0;
      _counterAnim = Tween<double>(begin: _counterAnim.value, end: widget.stats.calories)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _progressAnim = Tween<double>(begin: _progressAnim.value, end: ratio)
          .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pct = widget.calorieTarget > 0
        ? ((widget.stats.calories / widget.calorieTarget) * 100).clamp(0.0, 100.0)
        : 0.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        decoration: const BoxDecoration(gradient: AppGradients.nutrition),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nutrition', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _counterAnim.value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white, height: 1, letterSpacing: -2),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8, left: 6),
                        child: Text('kcal', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('objectif : ${widget.calorieTarget.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 13, color: Colors.white60)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progressAnim.value,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Macro grid animée ──────────────────────────────────────────────────────

class _AnimatedMacroGrid extends StatefulWidget {
  final DailyStats stats;
  final double proteinTarget;
  final double carbsTarget;
  final double fatTarget;

  const _AnimatedMacroGrid({
    required this.stats,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
  });

  @override
  State<_AnimatedMacroGrid> createState() => _AnimatedMacroGridState();
}

class _AnimatedMacroGridState extends State<_AnimatedMacroGrid> with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    Future.delayed(const Duration(milliseconds: 400), () { if (mounted) _c.forward(); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('PROTÉINES', widget.proteinTarget, 'g', const Color(0xFF059669), Icons.egg_alt_rounded, widget.stats.protein),
      ('GLUCIDES', widget.carbsTarget, 'g', const Color(0xFF0EA5E9), Icons.grain_rounded, widget.stats.carbs),
      ('LIPIDES', widget.fatTarget, 'g', const Color(0xFFF59E0B), Icons.water_drop_rounded, widget.stats.fat),
      ('SÉANCES', 5.0, '', const Color(0xFF7C3AED), Icons.fitness_center_rounded, widget.stats.workoutsCount.toDouble()),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: List.generate(items.length, (i) {
        final delay = i * 0.15;
        return AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = Curves.easeOutCubic.transform(
              ((_c.value - delay) / (1.0 - delay)).clamp(0.0, 1.0),
            );
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - t)),
                child: _MacroCard(
                  label: items[i].$1,
                  value: items[i].$6,
                  target: items[i].$2,
                  unit: items[i].$3,
                  color: items[i].$4,
                  icon: items[i].$5,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _MacroGridShimmer extends StatelessWidget {
  const _MacroGridShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: List.generate(4, (_) => const ShimmerStatCard()),
    );
  }
}

class _MacroCard extends StatefulWidget {
  final String label;
  final double value;
  final double target;
  final String unit;
  final Color color;
  final IconData icon;

  const _MacroCard({required this.label, required this.value, required this.target, required this.unit, required this.color, required this.icon});

  @override
  State<_MacroCard> createState() => _MacroCardState();
}

class _MacroCardState extends State<_MacroCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _prog;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    final ratio = widget.target > 0 ? (widget.value / widget.target).clamp(0.0, 1.0) : 0.0;
    _prog = Tween<double>(begin: 0, end: ratio).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _c.forward(); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _prog,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: widget.color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(widget.icon, size: 14, color: widget.color),
              ),
              const SizedBox(width: 6),
              Text(widget.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: widget.color)),
            ]),
            Text(
              widget.unit.isEmpty
                  ? '${widget.value.toStringAsFixed(0)} / ${widget.target.toStringAsFixed(0)}'
                  : '${widget.value.toStringAsFixed(0)} ${widget.unit}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: _prog.value, backgroundColor: widget.color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(widget.color), minHeight: 5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gradient Button ─────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.icon, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: (gradient as LinearGradient).colors.first.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ─── Meal Row ────────────────────────────────────────────────────────────────

class _MealRow extends StatelessWidget {
  final MealHistoryItem item;
  const _MealRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(gradient: AppGradients.nutrition, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(item.date, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
        Text('${item.calories.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    );
  }
}
