import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/features/feed/data/datasources/feed_local_storage.dart';
import 'package:healthai_coach_mobile/features/feed/domain/entities/comment.dart';
import 'package:healthai_coach_mobile/features/feed/domain/entities/post.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final post = Post(
    id: 'post_1',
    authorId: 'user_1',
    authorName: 'Alice',
    authorAvatar: '/tmp/avatar.png',
    content: 'Hello world',
    mediaUrl: '/tmp/photo.png',
    mediaType: 'image',
    likes: 3,
    likedByMe: true,
    commentsCount: 1,
    createdAt: DateTime(2026, 1, 1, 12, 0),
  );

  final comment = Comment(
    id: 'comment_1',
    postId: 'post_1',
    authorId: 'user_2',
    authorName: 'Bob',
    content: 'Nice!',
    createdAt: DateTime(2026, 1, 1, 12, 5),
  );

  group('FeedLocalStorage', () {
    test('loadPosts retourne null si aucune donnée sauvegardée', () async {
      final storage = FeedLocalStorage();
      expect(await storage.loadPosts(), isNull);
    });

    test('loadComments retourne null si aucune donnée sauvegardée', () async {
      final storage = FeedLocalStorage();
      expect(await storage.loadComments(), isNull);
    });

    test('savePosts puis loadPosts doit restaurer les mêmes données', () async {
      final storage = FeedLocalStorage();
      await storage.savePosts([post]);

      final loaded = await storage.loadPosts();

      expect(loaded, hasLength(1));
      expect(loaded!.first.id, post.id);
      expect(loaded.first.authorName, post.authorName);
      expect(loaded.first.authorAvatar, post.authorAvatar);
      expect(loaded.first.content, post.content);
      expect(loaded.first.mediaUrl, post.mediaUrl);
      expect(loaded.first.mediaType, post.mediaType);
      expect(loaded.first.likes, post.likes);
      expect(loaded.first.likedByMe, post.likedByMe);
      expect(loaded.first.commentsCount, post.commentsCount);
      expect(loaded.first.createdAt, post.createdAt);
    });

    test('saveComments puis loadComments doit restaurer les mêmes données', () async {
      final storage = FeedLocalStorage();
      await storage.saveComments({
        'post_1': [comment],
      });

      final loaded = await storage.loadComments();

      expect(loaded, isNotNull);
      expect(loaded!['post_1'], hasLength(1));
      expect(loaded['post_1']!.first.id, comment.id);
      expect(loaded['post_1']!.first.authorName, comment.authorName);
      expect(loaded['post_1']!.first.content, comment.content);
      expect(loaded['post_1']!.first.createdAt, comment.createdAt);
    });

    test('clear doit supprimer les données persistées', () async {
      final storage = FeedLocalStorage();
      await storage.savePosts([post]);
      await storage.saveComments({'post_1': [comment]});

      await storage.clear();

      expect(await storage.loadPosts(), isNull);
      expect(await storage.loadComments(), isNull);
    });
  });
}
