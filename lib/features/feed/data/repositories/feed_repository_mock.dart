import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/constants/local_storage_keys.dart';
import '../datasources/feed_local_storage.dart';

class FeedRepositoryMock implements FeedRepository {
  FeedRepositoryMock({FeedLocalStorage? storage})
      : _storage = storage ?? FeedLocalStorage();

  final FeedLocalStorage _storage;

  List<Post>? _posts;
  Map<String, List<Comment>>? _comments;

  /// Charge les données persistées (ou les données de démo au premier lancement).
  Future<void> _ensureLoaded() async {
    if (_posts != null && _comments != null) return;
    _posts = await _storage.loadPosts() ?? List<Post>.from(_initialPosts);
    _comments = await _storage.loadComments() ??
        _initialComments.map((k, v) => MapEntry(k, List<Comment>.from(v)));
  }

  Future<void> _persist() async {
    await _storage.savePosts(_posts!);
    await _storage.saveComments(_comments!);
  }

  /// Nom/avatar à utiliser pour les publications/commentaires de
  /// l'utilisateur courant, en cohérence avec ce qui est affiché sur
  /// l'écran Profil.
  Future<(String, String?)> _currentUserIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(LocalStorageKeys.profileDisplayName);
    final avatar = prefs.getString(LocalStorageKeys.profileAvatarPath);
    return (name?.isNotEmpty == true ? name! : 'Moi', avatar);
  }

  @override
  Future<List<Post>> getPosts({int page = 1, int limit = 20}) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 400));
    final start = (page - 1) * limit;
    if (start >= _posts!.length) return [];
    return _posts!.skip(start).take(limit).toList();
  }

  @override
  Future<Post> toggleLike(String postId) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _posts!.indexWhere((p) => p.id == postId);
    if (idx == -1) throw Exception('Post not found');
    final post = _posts![idx];
    final updated = post.copyWith(
      likedByMe: !post.likedByMe,
      likes: post.likedByMe ? post.likes - 1 : post.likes + 1,
    );
    _posts![idx] = updated;
    await _persist();
    return updated;
  }

  @override
  Future<Post> createPost({
    required String content,
    String? mediaPath,
    String? mediaType,
  }) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 800));
    final userId = await TokenStorage.getUserId() ?? 'me';
    final (authorName, authorAvatar) = await _currentUserIdentity();
    final post = Post(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: userId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content,
      mediaUrl: mediaPath,
      mediaType: mediaType,
      likes: 0,
      likedByMe: false,
      commentsCount: 0,
      createdAt: DateTime.now(),
    );
    _posts!.insert(0, post);
    _comments![post.id] = [];
    await _persist();
    return post;
  }

  @override
  Future<List<Comment>> getComments(String postId) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_comments![postId] ?? []);
  }

  @override
  Future<Comment> addComment({
    required String postId,
    required String content,
  }) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 300));
    final (authorName, _) = await _currentUserIdentity();
    final comment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorId: 'me',
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
    );
    _comments!.putIfAbsent(postId, () => []).add(comment);
    final idx = _posts!.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      _posts![idx] = _posts![idx].copyWith(
        commentsCount: _posts![idx].commentsCount + 1,
      );
    }
    await _persist();
    return comment;
  }
}

final _initialPosts = [
  Post(
    id: 'post_001',
    authorId: 'user_001',
    authorName: 'Sophie Moreau',
    content: 'Journée de récupération après mon semi-marathon de dimanche ! 🏃‍♀️ 21 km en 1h52, super fière de ma progression. La nutrition avant course a vraiment fait la différence cette fois.',
    likes: 24,
    likedByMe: false,
    commentsCount: 3,
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
  Post(
    id: 'post_002',
    authorId: 'user_002',
    authorName: 'Thomas Leblanc',
    content: 'Recette du moment : bowl protéiné quinoa + pois chiches + avocat + oeuf poché. ~520 kcal, 32g protéines. Parfait après la séance du matin 💪',
    likes: 41,
    likedByMe: true,
    commentsCount: 7,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Post(
    id: 'post_003',
    authorId: 'user_003',
    authorName: 'Camille Dupont',
    content: 'Question pour la communauté : est-ce que vous mangez avant ou après votre séance de yoga du matin ? J\'hésite encore entre les deux approches 🧘‍♀️',
    likes: 18,
    likedByMe: false,
    commentsCount: 12,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Post(
    id: 'post_004',
    authorId: 'user_004',
    authorName: 'Lucas Bernard',
    content: 'Semaine 4 de mon programme force — résultats : +8kg au squat, +5kg au développé couché. HealthAI Coach m\'a vraiment aidé à structurer mes séances et ma nutrition autour de l\'entraînement.',
    likes: 67,
    likedByMe: false,
    commentsCount: 5,
    createdAt: DateTime.now().subtract(const Duration(hours: 9)),
  ),
  Post(
    id: 'post_005',
    authorId: 'user_005',
    authorName: 'Inès Petit',
    content: 'Objectif atteint ! 🎉 -5kg en 2 mois avec un déficit calorique raisonnable et 3 séances/semaine. Pas de régime drastique, juste de la régularité. Courage à tous ceux qui commencent leur parcours !',
    likes: 103,
    likedByMe: true,
    commentsCount: 21,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

final _initialComments = <String, List<Comment>>{
  'post_001': [
    Comment(id: 'c_001_1', postId: 'post_001', authorId: 'user_002', authorName: 'Thomas Leblanc', content: 'Bravo Sophie ! 1h52 c\'est excellent pour un premier semi 🏅', createdAt: DateTime.now().subtract(const Duration(minutes: 30))),
    Comment(id: 'c_001_2', postId: 'post_001', authorId: 'user_004', authorName: 'Lucas Bernard', content: 'Tu as utilisé quel plan nutritionnel la semaine avant la course ?', createdAt: DateTime.now().subtract(const Duration(minutes: 20))),
    Comment(id: 'c_001_3', postId: 'post_001', authorId: 'user_003', authorName: 'Camille Dupont', content: 'Super performance ! Repose-toi bien 😊', createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
  ],
  'post_002': [
    Comment(id: 'c_002_1', postId: 'post_002', authorId: 'user_001', authorName: 'Sophie Moreau', content: 'Je vais tester ça ce week-end, merci pour la recette !', createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45))),
    Comment(id: 'c_002_2', postId: 'post_002', authorId: 'user_005', authorName: 'Inès Petit', content: 'Le quinoa c\'est tellement polyvalent. Est-ce que tu ajoutes quelque chose pour la saveur ?', createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30))),
  ],
  'post_003': [
    Comment(id: 'c_003_1', postId: 'post_003', authorId: 'user_001', authorName: 'Sophie Moreau', content: 'Moi je préfère à jeun le matin pour le yoga, ça évite les ballonnements', createdAt: DateTime.now().subtract(const Duration(hours: 4))),
    Comment(id: 'c_003_2', postId: 'post_003', authorId: 'user_002', authorName: 'Thomas Leblanc', content: 'Ça dépend de l\'intensité. Pour du yin yoga je mange pas avant, pour du vinyasa je prends une petite banane', createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 30))),
  ],
  'post_004': [
    Comment(id: 'c_004_1', postId: 'post_004', authorId: 'user_003', authorName: 'Camille Dupont', content: 'Impressionnant ! En combien de séances par semaine ?', createdAt: DateTime.now().subtract(const Duration(hours: 7))),
  ],
  'post_005': [
    Comment(id: 'c_005_1', postId: 'post_005', authorId: 'user_001', authorName: 'Sophie Moreau', content: 'Incroyable Inès, tu es une inspiration pour tous ! 🌟', createdAt: DateTime.now().subtract(const Duration(hours: 20))),
    Comment(id: 'c_005_2', postId: 'post_005', authorId: 'user_002', authorName: 'Thomas Leblanc', content: 'Chapeau ! C\'est exactement ça, la régularité bat l\'intensité', createdAt: DateTime.now().subtract(const Duration(hours: 18))),
  ],
};
