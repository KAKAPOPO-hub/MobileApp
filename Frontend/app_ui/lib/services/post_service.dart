import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/post.dart';
import 'auth_session.dart';

class PostService {
  const PostService();

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/v1/posts'));
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
      throw const PostServiceException('Response posts dari server tidak valid');
    }

    return postsData
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }

  Future<Post> createPost({
    required String title,
    required String content,
    File? coverImage,
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
