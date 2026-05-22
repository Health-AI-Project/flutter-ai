import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
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
                  itemBuilder: (_, i) => PostCard(post: posts[i]),
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
