class PostAuthor {
  const PostAuthor({required this.id, required this.username});

  final int id;
  final String username;

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as int,
      username: json['username'] as String,
    );
  }
}

class PostCategory {
  const PostCategory({required this.id, required this.name});

  final int id;
  final String name;

  factory PostCategory.fromJson(Map<String, dynamic> json) {
    return PostCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String,
    );
  }
}

class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.categoryId,
    this.author,
    this.category,
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
  final int? categoryId;
  final PostAuthor? author;
  final PostCategory? category;
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
      categoryId: json['categoryId'] as int?,
        author: json['author'] is Map<String, dynamic>
          ? PostAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
          category: json['category'] is Map<String, dynamic>
            ? PostCategory.fromJson(json['category'] as Map<String, dynamic>)
            : null,
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
