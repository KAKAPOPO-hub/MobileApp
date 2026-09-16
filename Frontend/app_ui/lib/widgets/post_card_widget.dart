import 'package:flutter/material.dart';

import '../pages/post.dart';

const _primaryColor = Color(0xFF6557E8);
const _inkColor = Color(0xFF20202D);
const _mutedColor = Color(0xFF77768A);
const _postCardColor = Color(0xFFF4F2FF);
const _postBorderColor = Color(0xFFE7E4FA);

class PostCardWidget extends StatelessWidget {
  const PostCardWidget({
    super.key,
    required this.post,
    this.onTap,
    this.showBookmark = true,
  });

  final Post post;
  final VoidCallback? onTap;
  final bool showBookmark;

  @override
  Widget build(BuildContext context) {
    final username = post.author?.username ?? 'Akun pengguna';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: _postCardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _postBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha: 0.055),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                    Image.network(
                      post.imageUrl!,
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return _ImagePlaceholder();
                      },
                    )
                  else
                    const _ImagePlaceholder(),
                  if (showBookmark)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 16, 17, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$username',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: _primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: _inkColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: _mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          '5 min read',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: _mutedColor.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Read more',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: _primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      color: const Color(0xFFEAE8F5),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: _mutedColor,
          size: 30,
        ),
      ),
    );
  }
}
