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
      body: feedAsync.when(
        loading: () => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHero(context, ref, null)),
            SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ShimmerCard(),
                  ),
                  childCount: 4,
                ),
              ),
            ),
          ],
        ),
        error: (err, _) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHero(context, ref, null)),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    const Text('Impossible de charger le feed',
                        style:
                            TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(feedProvider.notifier).refresh(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        data: (posts) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(feedProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: _buildHero(context, ref, posts.length)),
              posts.isEmpty
                  ? const SliverFillRemaining(child: _EmptyFeed())
                  : SliverPadding(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _AnimatedPostItem(
                            index: i,
                            child: PostCard(post: posts[i]),
                          ),
                          childCount: posts.length,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(
      BuildContext context, WidgetRef ref, int? postsCount) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.feed),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Communauté',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Partage',
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                          letterSpacing: -1.5)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/create-post'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Publier',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (postsCount != null)
                Text('$postsCount publication${postsCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white60))
              else
                const Text('Chargement…',
                    style:
                        TextStyle(fontSize: 13, color: Colors.white60)),
            ],
          ),
        ),
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
    _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400));
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

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
        Icon(Icons.people_outline,
            size: 56, color: AppColors.textTertiary),
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
          style:
              TextStyle(fontSize: 13, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
