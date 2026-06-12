import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/feed/presentation/providers/feed_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FeedNotifier', () {
    test('build charge la liste initiale des publications', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final posts = await container.read(feedProvider.future);

      expect(posts, isNotEmpty);
    });

    test('toggleLike met à jour le like de la publication ciblée', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final posts = await container.read(feedProvider.future);
      final target = posts.first;

      await container.read(feedProvider.notifier).toggleLike(target.id);

      final updated = container.read(feedProvider).value!
          .firstWhere((p) => p.id == target.id);
      expect(updated.likedByMe, !target.likedByMe);
    });

    test('createPost ajoute la publication en tête de liste', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialPosts = await container.read(feedProvider.future);

      final created = await container
          .read(feedProvider.notifier)
          .createPost(content: 'Nouveau post de test');

      final posts = container.read(feedProvider).value!;
      expect(posts.length, initialPosts.length + 1);
      expect(posts.first.id, created!.id);
      expect(posts.first.content, 'Nouveau post de test');
    });

    test('refresh recharge la liste depuis le repository', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(feedProvider.future);
      await container.read(feedProvider.notifier).refresh();

      final posts = container.read(feedProvider).value;
      expect(posts, isNotNull);
      expect(posts, isNotEmpty);
    });
  });

  group('CommentsNotifier', () {
    test('addComment ajoute un commentaire et incrémente commentsCount du post', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final posts = await container.read(feedProvider.future);
      final target = posts.first;

      await container.read(commentsProvider(target.id).future);
      await container.read(commentsProvider(target.id).notifier).addComment('Mon commentaire');

      final comments = container.read(commentsProvider(target.id)).value!;
      expect(comments.any((c) => c.content == 'Mon commentaire'), isTrue);

      final updatedPost = container.read(feedProvider).value!
          .firstWhere((p) => p.id == target.id);
      expect(updatedPost.commentsCount, target.commentsCount + 1);
    });
  });
}
