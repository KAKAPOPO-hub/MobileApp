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
      barColor: Colors.white,
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
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(), // fix stretch overscroll
          slivers: [
            // Search bar + Jumbotron -> tidak perlu lazy, cukup sekali build
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(
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
                  ],
                ),
              ),
            ),

            // Post list -> lazy, hanya build yang keliatan di layar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              sliver: const PostSliverList(),
            ),
          ],
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

/// Sliver lazy-list buat post, lengkap dengan separator antar item.
class PostSliverList extends StatefulWidget {
  const PostSliverList({super.key});

  @override
  State<PostSliverList> createState() => _PostSliverListState();
}

class _PostSliverListState extends State<PostSliverList> {
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
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Row(
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
            ),
          );
        }

        final posts = snapshot.data ?? const <Post>[];
        if (posts.isEmpty) {
          return SliverToBoxAdapter(
            child: Text(
              'Belum ada post',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        // Trik separator di sliver: index genap = card, index ganjil = separator.
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index.isOdd) {
                return const SizedBox(height: 20); // ganti Divider() kalau mau garis
              }
              final postIndex = index ~/ 2;
              return _buildPostCard(posts[postIndex]);
            },
            childCount: posts.isEmpty ? 0 : posts.length * 2 - 1,
          ),
        );
      },
    );
  }

  Widget _buildPostCard(Post post) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                color: Colors.grey.shade800,
              ),
            )
          else
            Container(height: 220, color: Colors.grey.shade800),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                post.category ?? 'SASTRA',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bookmark_border, color: Colors.white, size: 16),
            ),
          ),

          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}