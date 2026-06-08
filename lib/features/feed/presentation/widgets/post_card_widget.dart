import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/theme.dart';
import '../../domain/entities/post.dart';
import '../providers/feed_provider.dart';
import 'like_button_widget.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(),
          if (post.mediaUrl != null) _buildMedia(),
          _buildActions(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        children: [
          _Avatar(name: post.authorName, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _timeAgo(post.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Text(
        post.content,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildMedia() {
    final url = post.mediaUrl!;
    final isLocal = url.startsWith('/');
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      ),
      child: isLocal
          ? Image.file(
              File(url),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            )
          : Image.network(
              url,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 14, 10),
      child: Row(
        children: [
          LikeButton(
            count: post.likes,
            liked: post.likedByMe,
            onTap: () => ref.read(feedProvider.notifier).toggleLike(post.id),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/comments', extra: post),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 17, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${post.commentsCount}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;

  const _Avatar({required this.name, required this.size});

  Color _colorFor(String name) {
    final colors = [
      const Color(0xFF1D9E75),
      const Color(0xFF5B8DEF),
      const Color(0xFFF4856A),
      const Color(0xFFFAC775),
      const Color(0xFF9C6EDE),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _colorFor(name),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.38,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
