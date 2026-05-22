import '../entities/post.dart';
import '../entities/comment.dart';

abstract class FeedRepository {
  Future<List<Post>> getPosts({int page = 1, int limit = 20});
  Future<Post> toggleLike(String postId);
  Future<Post> createPost({required String content, String? mediaPath, String? mediaType});
  Future<List<Comment>> getComments(String postId);
  Future<Comment> addComment({required String postId, required String content});
}
