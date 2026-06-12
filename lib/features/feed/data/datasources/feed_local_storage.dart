import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';

/// Persistance locale (mock) du feed communautaire.
///
/// Tant que l'API réseau social n'existe pas côté backend, on simule la
/// "sauvegarde/restauration des données locales" demandée par le cahier des
/// charges en conservant les publications, likes et commentaires dans
/// SharedPreferences. Le format JSON utilisé ici correspond à ce qu'une
/// future API REST renverrait, ce qui facilite le branchement ultérieur.
class FeedLocalStorage {
  static const _postsKey = 'feed_posts_cache_v1';
  static const _commentsKey = 'feed_comments_cache_v1';

  Future<List<Post>?> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_postsKey);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => postFromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _postsKey,
      jsonEncode(posts.map(postToJson).toList()),
    );
  }

  Future<Map<String, List<Comment>>?> loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_commentsKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((postId, value) => MapEntry(
          postId,
          (value as List<dynamic>)
              .map((e) => commentFromJson(e as Map<String, dynamic>))
              .toList(),
        ));
  }

  Future<void> saveComments(Map<String, List<Comment>> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = comments.map(
      (postId, list) => MapEntry(postId, list.map(commentToJson).toList()),
    );
    await prefs.setString(_commentsKey, jsonEncode(encoded));
  }

  /// Supprime le cache local (remise à zéro de la démo).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_postsKey);
    await prefs.remove(_commentsKey);
  }

  Map<String, dynamic> postToJson(Post post) => {
        'id': post.id,
        'authorId': post.authorId,
        'authorName': post.authorName,
        'authorAvatar': post.authorAvatar,
        'content': post.content,
        'mediaUrl': post.mediaUrl,
        'mediaType': post.mediaType,
        'likes': post.likes,
        'likedByMe': post.likedByMe,
        'commentsCount': post.commentsCount,
        'createdAt': post.createdAt.toIso8601String(),
      };

  Post postFromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String,
        authorAvatar: json['authorAvatar'] as String?,
        content: json['content'] as String,
        mediaUrl: json['mediaUrl'] as String?,
        mediaType: json['mediaType'] as String?,
        likes: json['likes'] as int,
        likedByMe: json['likedByMe'] as bool,
        commentsCount: json['commentsCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> commentToJson(Comment comment) => {
        'id': comment.id,
        'postId': comment.postId,
        'authorId': comment.authorId,
        'authorName': comment.authorName,
        'content': comment.content,
        'createdAt': comment.createdAt.toIso8601String(),
      };

  Comment commentFromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        postId: json['postId'] as String,
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
