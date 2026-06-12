import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../data/repositories/feed_repository_mock.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (_) => FeedRepositoryMock(),
);

// --- Feed notifier ---

class FeedNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() => _load();

  Future<List<Post>> _load() {
    final repo = ref.read(feedRepositoryProvider);
    return repo.getPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> toggleLike(String postId) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      final updated = await repo.toggleLike(postId);
      state = AsyncData(
        state.valueOrNull?.map((p) => p.id == postId ? updated : p).toList() ?? [],
      );
    } catch (_) {}
  }

  Future<Post?> createPost({required String content, String? mediaPath, String? mediaType}) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      final post = await repo.createPost(
        content: content,
        mediaPath: mediaPath,
        mediaType: mediaType,
      );
      state = AsyncData([post, ...?state.valueOrNull]);
      return post;
    } catch (_) {
      return null;
    }
  }
}

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Post>>(FeedNotifier.new);

// --- Comments notifier ---

class CommentsNotifier extends FamilyAsyncNotifier<List<Comment>, String> {
  @override
  Future<List<Comment>> build(String postId) {
    final repo = ref.read(feedRepositoryProvider);
    return repo.getComments(postId);
  }

  Future<void> addComment(String content) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      final comment = await repo.addComment(postId: arg, content: content);
      state = AsyncData([...?state.valueOrNull, comment]);
      // Update commentsCount in feed
      ref.read(feedProvider.notifier).state = AsyncData(
        ref.read(feedProvider).valueOrNull?.map((p) {
          if (p.id == arg) return p.copyWith(commentsCount: p.commentsCount + 1);
          return p;
        }).toList() ?? [],
      );
    } catch (_) {}
  }
}

final commentsProvider =
    AsyncNotifierProviderFamily<CommentsNotifier, List<Comment>, String>(
  CommentsNotifier.new,
);
