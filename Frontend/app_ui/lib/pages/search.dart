import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Post>> _postsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _postsFuture = const PostService().getPosts();
    _searchController.addListener(_updateQuery);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_updateQuery)
      ..dispose();
    super.dispose();
  }

  void _updateQuery() {
    setState(() => _query = _searchController.text.trim().toLowerCase());
  }

  void _reloadPosts() {
    setState(() => _postsFuture = const PostService().getPosts());
  }

  bool _matches(Post post) {
    if (_query.isEmpty) return true;
    final author = post.author?.username.toLowerCase() ?? '';
    return post.title.toLowerCase().contains(_query) ||
        post.content.toLowerCase().contains(_query) ||
        author.contains(_query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Discovery',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return _ErrorState(onRetry: _reloadPosts);

          final posts = (snapshot.data ?? const <Post>[]).where(_matches).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari post atau akun',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: _searchController.clear,
                            icon: const Icon(Icons.clear),
                          ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Hasil post orang',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: posts.isEmpty
                    ? const Center(child: Text('Post tidak ditemukan'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: posts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _DiscoveryPostCard(
                          post: posts[index],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DiscoveryPostCard extends StatelessWidget {
  const _DiscoveryPostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final username = post.author?.username ?? 'Akun pengguna';
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              height: 190,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 40),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '@$username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Gagal memuat Discovery'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
