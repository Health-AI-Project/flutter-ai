import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card_widget.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Communauté',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: feedAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: 4,
          itemBuilder: (_, __) => const ShimmerCard(),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              const Text(
                'Impossible de charger le feed',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(feedProvider.notifier).refresh(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (posts) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(feedProvider.notifier).refresh(),
          child: posts.isEmpty
              ? const _EmptyFeed()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: posts.length,
                  itemBuilder: (_, i) => _AnimatedPostItem(
                    index: i,
                    child: PostCard(post: posts[i]),
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/create-post'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AnimatedPostItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedPostItem({required this.index, required this.child});

  @override
  State<_AnimatedPostItem> createState() => _AnimatedPostItemState();
}

class _AnimatedPostItemState extends State<_AnimatedPostItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.people_outline, size: 56, color: AppColors.textTertiary),
        SizedBox(height: 16),
        Text(
          'Soyez le premier à publier !',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Partagez vos succès avec la communauté',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
