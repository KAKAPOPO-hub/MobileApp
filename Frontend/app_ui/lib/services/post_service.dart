import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../pages/post.dart';
import 'auth_session.dart';

class PostService {
  const PostService();

  Future<List<Post>> getPosts({String? search, String? category}) async {
    final queryParameters = <String, String>{
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (category != null && category != 'All') 'category': category,
    };
    final uri = Uri.parse('$apiBaseUrl/api/v1/posts')
        .replace(queryParameters: queryParameters);
    final response = await http.get(uri);
    final responseBody = response.body;

    if (response.statusCode != 200) {
      throw PostServiceException(
        _readMessage(responseBody) ??
            'Gagal mengambil posts (${response.statusCode})',
      );
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final postsData = (data['data'] as Map<String, dynamic>)['posts'];
    if (postsData is! List) {
      throw const PostServiceException(
        'Response posts dari server tidak valid',
      );
    }

    return postsData
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }

  Future<Post> getPostById(int postId) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/v1/posts/$postId'),
    );
    final responseBody = response.body;

    if (response.statusCode != 200) {
      throw PostServiceException(
        _readMessage(responseBody) ??
            'Gagal mengambil detail post (${response.statusCode})',
      );
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final postData = (data['data'] as Map<String, dynamic>)['post'];
    if (postData is! Map<String, dynamic>) {
      throw const PostServiceException(
        'Response detail post dari server tidak valid',
      );
    }

    return Post.fromJson(postData);
  }

  Future<List<Post>> getMyPosts() async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw const PostServiceException('Silakan login terlebih dahulu');
    }

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/v1/users/me/posts'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final responseBody = response.body;
    if (response.statusCode != 200) {
      throw PostServiceException(
        _readMessage(responseBody) ?? 'Gagal mengambil activity',
      );
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final postsData = (data['data'] as Map<String, dynamic>)['posts'];
    if (postsData is! List) {
      throw const PostServiceException('Response activity tidak valid');
    }
    return postsData
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }

  Future<void> updatePost({
    required int postId,
    required String title,
    required String content,
    int? categoryId,
  }) async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw const PostServiceException('Silakan login terlebih dahulu');
    }
    final response = await http.patch(
      Uri.parse('$apiBaseUrl/api/v1/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title.trim(),
        'content': content.trim(),
        'categoryId': categoryId,
      }),
    );
    if (response.statusCode != 200) {
      throw PostServiceException(
        _readMessage(response.body) ?? 'Gagal mengubah post',
      );
    }
  }

  Future<Post> createPost({
    required String title,
    required String content,
    File? coverImage,
    int? categoryId,
  }) async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw const PostServiceException('Silakan login terlebih dahulu');
    }

    final request =
        http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/api/v1/posts'))
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['title'] = title.trim()
          ..fields['content'] = content.trim();

    if (categoryId != null) {
      request.fields['categoryId'] = categoryId.toString();
    }

    if (coverImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', coverImage.path),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw PostServiceException(
        _readMessage(responseBody) ??
            'Gagal membuat post (${response.statusCode})',
      );
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final postData = (data['data'] as Map<String, dynamic>)['post'];
    if (postData is! Map<String, dynamic>) {
      throw const PostServiceException('Response post dari server tidak valid');
    }

    return Post.fromJson(postData);
  }

  Future<void> deletePost(int postId) async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw const PostServiceException('Silakan login terlebih dahulu');
    }

    final response = await http.delete(
      Uri.parse('$apiBaseUrl/api/v1/posts/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw PostServiceException(
        _readMessage(response.body) ??
            'Gagal menghapus post (${response.statusCode})',
      );
    }
  }

  String? _readMessage(String responseBody) {
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      return data['message']?.toString();
    } catch (_) {
      return null;
    }
  }
}

class PostServiceException implements Exception {
  const PostServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
