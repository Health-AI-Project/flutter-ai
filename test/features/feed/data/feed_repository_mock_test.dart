import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_coach_mobile/core/constants/local_storage_keys.dart';
import 'package:healthai_coach_mobile/features/feed/data/repositories/feed_repository_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FeedRepositoryMock', () {
    test('getPosts retourne les publications de démo au premier lancement', () async {
      final repo = FeedRepositoryMock();
      final posts = await repo.getPosts();
      expect(posts, isNotEmpty);
    });

    test('toggleLike est persisté entre deux instances du repository', () async {
      final repo1 = FeedRepositoryMock();
      final posts = await repo1.getPosts();
      final target = posts.first;

      final updated = await repo1.toggleLike(target.id);
      expect(updated.likedByMe, !target.likedByMe);

      final repo2 = FeedRepositoryMock();
      final reloaded = await repo2.getPosts();
      final reloadedPost = reloaded.firstWhere((p) => p.id == target.id);

      expect(reloadedPost.likedByMe, updated.likedByMe);
      expect(reloadedPost.likes, updated.likes);
    });

    test('createPost utilise le nom et l\'avatar enregistrés sur le profil', () async {
      SharedPreferences.setMockInitialValues({
        LocalStorageKeys.profileDisplayName: 'Killian Pinte',
        LocalStorageKeys.profileAvatarPath: '/tmp/me.png',
      });

      final repo = FeedRepositoryMock();
      final post = await repo.createPost(content: 'Mon nouveau post');

      expect(post.authorName, 'Killian Pinte');
      expect(post.authorAvatar, '/tmp/me.png');
      expect(post.content, 'Mon nouveau post');
    });

    test('createPost utilise "Moi" par défaut si aucun nom n\'est enregistré', () async {
      final repo = FeedRepositoryMock();
      final post = await repo.createPost(content: 'Sans nom de profil');

      expect(post.authorName, 'Moi');
      expect(post.authorAvatar, isNull);
    });

    test('createPost est persisté entre deux instances du repository', () async {
      final repo1 = FeedRepositoryMock();
      final created = await repo1.createPost(content: 'Post persistant');

      final repo2 = FeedRepositoryMock();
      final reloaded = await repo2.getPosts();

      expect(reloaded.first.id, created.id);
      expect(reloaded.first.content, 'Post persistant');
    });

    test('addComment utilise le nom enregistré sur le profil et incrémente commentsCount', () async {
      SharedPreferences.setMockInitialValues({
        LocalStorageKeys.profileDisplayName: 'Killian Pinte',
      });

      final repo = FeedRepositoryMock();
      final posts = await repo.getPosts();
      final target = posts.first;

      final comment = await repo.addComment(postId: target.id, content: 'Super !');
      expect(comment.authorName, 'Killian Pinte');

      final updatedPosts = await repo.getPosts();
      final updatedPost = updatedPosts.firstWhere((p) => p.id == target.id);
      expect(updatedPost.commentsCount, target.commentsCount + 1);
    });

    test('addComment est persisté entre deux instances du repository', () async {
      final repo1 = FeedRepositoryMock();
      final posts = await repo1.getPosts();
      final target = posts.first;

      await repo1.addComment(postId: target.id, content: 'Commentaire persistant');

      final repo2 = FeedRepositoryMock();
      final comments = await repo2.getComments(target.id);

      expect(comments.any((c) => c.content == 'Commentaire persistant'), isTrue);
    });
  });
}
