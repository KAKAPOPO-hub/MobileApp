import 'package:app_ui/pages/create.dart';
import 'package:flutter/material.dart';
import 'activity.dart';
import 'message.dart';
import 'post_detail.dart';
import 'profile.dart';
import 'search.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/post_card_widget.dart';
import '../widgets/search_bar_widget.dart';

import 'post.dart';
import '../services/post_service.dart';

const _primaryColor = Color(0xFF6557E8);
const _backgroundColor = Colors.white;
const _inkColor = Color(0xFF20202D);
const _mutedColor = Color(0xFF77768A);

const _postCardColor = Color(0xFFF4F2FF);
const _postBorderColor = Color(0xFFE7E4FA);

class Home extends StatelessWidget {
  const Home({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return AppBottomNavBar(
      initialIndex: initialIndex,
      barColor: Colors.white,
      items: const [
        NavItem(
          icon: Icons.home_rounded,
          page: _HomeContent(),
        ),
        NavItem(
          icon: Icons.explore_rounded,
          page: SearchPage(),
        ),
        NavItem(
          icon: Icons.menu_book_rounded,
          page: CreatePage(),
        ),
        NavItem(
          icon: Icons.message_rounded,
          page: MessagePage(),
        ),
        NavItem(
          icon: Icons.notifications_rounded,
          page: ActivityPage(),
        ),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: AppBar(
        backgroundColor: _backgroundColor,
        surfaceTintColor: _backgroundColor,
        elevation: 0,

        title: const Text(
          'Home',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: _inkColor,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(
              Icons.person_rounded,
            ),
            iconSize: 21,
            color: _inkColor,


            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                0,
              ),

              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchBarWidget(
                      hintText: 'Cari post',
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Featured',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _inkColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Jumbotron(),
                    const SizedBox(height: 24),
                    const Text(
                      'Popular Posts',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _inkColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                110,
              ),

              sliver: const PostSliverList(),
            ),
          ],
        ),
      ),
    );
  }
}


class Jumbotron extends StatelessWidget {
  const Jumbotron({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/image/carousel1.jpg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withValues(alpha: 0.35),
              Colors.black.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Baca cerita baru hari ini',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class PostSliverList extends StatefulWidget {
  const PostSliverList({super.key});

  @override
  State<PostSliverList> createState() =>
      _PostSliverListState();
}

class _PostSliverListState
    extends State<PostSliverList> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();

    _postsFuture =
        const PostService().getPosts();
  }

  void _reloadPosts() {
    setState(() {
      _postsFuture =
          const PostService().getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 32,
              ),

              child: Center(
                child: CircularProgressIndicator(
                  color: _primaryColor,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          );
        }


        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                8,
                14,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FC),

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: const Color(0xFFEAE8F2),
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: _primaryColor,
                    size: 22,
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Post belum dapat dimuat. Coba lagi.',

                      style: TextStyle(
                        color: _inkColor,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: 'Coba lagi',

                    onPressed: _reloadPosts,

                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),

                    color: _primaryColor,
                  ),
                ],
              ),
            ),
          );
        }

        final posts =
            snapshot.data ?? const <Post>[];

        if (posts.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                vertical: 24,
              ),

              decoration: BoxDecoration(
                color: _postCardColor,

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: _postBorderColor,
                ),
              ),

              child: const Column(
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: _primaryColor,
                    size: 26,
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Belum ada post',

                    style: TextStyle(
                      color: _mutedColor,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index.isOdd) {
                return const SizedBox(
                  height: 20,
                );
              }

              final postIndex = index ~/ 2;

              return _buildPostCard(
                posts[postIndex],
              );
            },

            childCount:
                posts.length * 2 - 1,
          ),
        );
      },
    );
  }

  Widget _buildPostCard(Post post) {
    return PostCardWidget(
      post: post,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailPage(post: post),
          ),
        );
      },
    );
  }
}