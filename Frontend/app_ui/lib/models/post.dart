class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.imagePublicId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final String title;
  final String content;
  final String? imageUrl;
  final String? imagePublicId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      imagePublicId: json['imagePublicId'] as String?,
      status: json['status'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    return value is String ? DateTime.tryParse(value) : null;
  }
}
