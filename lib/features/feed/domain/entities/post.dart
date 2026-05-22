class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? mediaUrl;
  final String? mediaType; // 'image' | 'video'
  final int likes;
  final bool likedByMe;
  final int commentsCount;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    required this.likes,
    required this.likedByMe,
    required this.commentsCount,
    required this.createdAt,
  });

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    String? mediaUrl,
    String? mediaType,
    int? likes,
    bool? likedByMe,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      likes: likes ?? this.likes,
      likedByMe: likedByMe ?? this.likedByMe,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
