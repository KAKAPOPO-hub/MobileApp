import 'package:flutter/material.dart';

import 'post.dart';
import '../services/post_service.dart';
import '../widgets/category_chip_widget.dart';
import '../widgets/post_card_widget.dart';
import '../widgets/search_bar_widget.dart';
import 'post_detail.dart';

const _primaryColor = Color(0xFF6557E8);
const _backgroundColor = Colors.white;
const _inkColor = Color(0xFF20202D);
const _mutedColor = Color(0xFF77768A);

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController =
      TextEditingController();

  late Future<List<Post>> _postsFuture;

  String _query = '';

  int _selectedCategory = 0;

  final List<String> _categories = [
    'All',
    'Puisi',
    'Pantun',
    'Sajak',
    'Cerpen',
  ];

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
    setState(() {
      _query =
          _searchController.text.trim().toLowerCase();
      _postsFuture = const PostService().getPosts(
        search: _searchController.text,
        category: _categories[_selectedCategory],
      );
    });
  }

  void _reloadPosts() {
    setState(() {
      _postsFuture =
          const PostService().getPosts(
            search: _searchController.text,
            category: _categories[_selectedCategory],
          );
    });
  }

  bool _matches(Post post) {
    if (_query.isEmpty) {
      return true;
    }

    final author =
        post.author?.username.toLowerCase() ?? '';

    return post.title
            .toLowerCase()
            .contains(_query) ||
        post.content
            .toLowerCase()
            .contains(_query) ||
        author.contains(_query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: AppBar(
        backgroundColor: _backgroundColor,
        surfaceTintColor: _backgroundColor,
        elevation: 0,

        title: const Text(
          'Discovery',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: _inkColor,
          ),
        ),
      ),

      body: FutureBuilder<List<Post>>(
        future: _postsFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _primaryColor,
                strokeWidth: 2.5,
              ),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              onRetry: _reloadPosts,
            );
          }

          final posts = (snapshot.data ??
                  const <Post>[])
              .where(_matches)
              .toList();

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                child: SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Cari post atau akun',
                  onChanged: (_) => _updateQuery(),
                  onClear: _searchController.clear,
                ),
              ),


              SizedBox(
                height: 38,

                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  scrollDirection:
                      Axis.horizontal,

                  physics:
                      const BouncingScrollPhysics(),

                  itemCount:
                      _categories.length,

                  itemBuilder:
                      (context, index) {
                    final selected =
                        _selectedCategory == index;

                    return CategoryChipWidget(
                      label: _categories[index],
                      selected: selected,
                      onTap: () {
                        setState(() {
                          _selectedCategory = index;
                          _postsFuture = const PostService().getPosts(
                            search: _searchController.text,
                            category: _categories[index],
                          );
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),


              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,

                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Explore Posts',
                            style: TextStyle(
                              fontFamily:
                                  'Poppins',

                              fontSize: 19,

                              fontWeight:
                                  FontWeight.w700,

                              letterSpacing:
                                  -0.2,

                              color:
                                  _inkColor,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Discover stories from the community',
                            style: TextStyle(
                              fontFamily:
                                  'Poppins',

                              fontSize: 11,

                              fontWeight:
                                  FontWeight.w400,

                              color:
                                  _mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_query.isNotEmpty)
                      Text(
                        '${posts.length} result',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              _primaryColor,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),


              Expanded(
                child: posts.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          20,
                          0,
                          20,
                          30,
                        ),

                        physics:
                            const BouncingScrollPhysics(),

                        itemCount:
                            posts.length,

                        separatorBuilder:
                          (_, _) =>
                                const SizedBox(
                          height: 18,
                        ),

                        itemBuilder:
                            (context, index) {
                          final post = posts[index];
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
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class _EmptyState
    extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 40,
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 64,
              height: 64,

              decoration:
                  BoxDecoration(
                color:
                    _primaryColor.withValues(
                  alpha: 0.10,
                ),

                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons.search_off_rounded,

                color:
                    _primaryColor,

                size: 28,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Post tidak ditemukan',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontFamily: 'Poppins',

                color:
                    _inkColor,

                fontSize: 15,

                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Coba gunakan kata kunci lain untuk menemukan post yang kamu cari.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontFamily: 'Poppins',

                color:
                    _mutedColor,

                fontSize: 11,

                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ErrorState
    extends StatelessWidget {
  const _ErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 40,
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 64,
              height: 64,

              decoration:
                  BoxDecoration(
                color:
                    _primaryColor.withValues(
                  alpha: 0.10,
                ),

                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons.cloud_off_rounded,

                color:
                    _primaryColor,

                size: 28,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Gagal memuat Discovery',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontFamily: 'Poppins',

                color:
                    _inkColor,

                fontSize: 15,

                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Terjadi masalah saat mengambil post. Silakan coba lagi.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontFamily: 'Poppins',

                color:
                    _mutedColor,

                fontSize: 11,

                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: onRetry,

              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    _primaryColor,

                side:
                    const BorderSide(
                  color:
                      _primaryColor,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),

              child: const Text(
                'Coba lagi',

                style: TextStyle(
                  fontFamily:
                      'Poppins',

                  fontSize: 11,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}