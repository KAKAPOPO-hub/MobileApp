import 'package:app_ui/pages/read.dart';
import 'package:flutter/material.dart';
import 'create.dart';
import 'message.dart';
import 'profile.dart';
import 'search.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'dart:async';

import '../models/post.dart';
import '../services/post_service.dart';

class Home extends StatelessWidget {
  const Home({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return AppBottomNavBar(
      initialIndex: initialIndex,
      barColor:Colors.white ,
      items: const [
        NavItem(icon: Icons.home_rounded, page: _HomeContent()),
        NavItem(icon: Icons.bookmark, page: SearchPage()),
        NavItem(icon: Icons.menu_book_rounded, page: Readpage()),
        NavItem(icon: Icons.message_rounded, page: MessagePage()),
        NavItem(icon: Icons.notifications_rounded, page: ProfilePage()),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePage()),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 24),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Cari post',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Jumbotron(),
              const SizedBox(height: 20),
              const PostCard()
            ],
          ),
        ),
      ),
    );
  }
}

class Jumbotron extends StatefulWidget {
  const Jumbotron({super.key});

  @override
  State<Jumbotron> createState() => _JumbotronState();
}

class _JumbotronState extends State<Jumbotron> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  final List<String> _slides = [
    'assets/image/carousel1.jpg',
    'assets/image/carousel 2.jpg',
    'assets/image/carousel 3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.55,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                return Image.asset(_slides[index], fit: BoxFit.cover);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < _slides.length; index++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.deepPurple
                      : Colors.deepPurple.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Popular Posts",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class PostCard extends StatefulWidget {
  const PostCard({super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = const PostService().getPosts();
  }

  void _reloadPosts() {
    setState(() => _postsFuture = const PostService().getPosts());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  snapshot.error.toString(),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              IconButton(
                tooltip: 'Coba lagi',
                onPressed: _reloadPosts,
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
        }

        final posts = snapshot.data ?? const <Post>[];
        if (posts.isEmpty) {
          return Text(
            'Belum ada post',
            style: TextStyle(color: Colors.grey.shade600),
          );
        }

        return Column(
          children: [
            for (final post in posts) _buildPostCard(post),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              height: 170,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}