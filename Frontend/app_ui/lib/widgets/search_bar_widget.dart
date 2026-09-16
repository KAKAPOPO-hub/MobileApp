import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.controller,
    this.hintText = 'Cari post',
    this.onTap,
    this.onChanged,
    this.onClear,
    this.readOnly = false,
    this.showClear = true,
  });

  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool readOnly;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAEAF3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: themeColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: readOnly
                  ? Text(
                      hintText,
                      style: const TextStyle(
                        color: Color(0xFF77768A),
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      readOnly: readOnly,
                      style: const TextStyle(
                        color: Color(0xFF20202D),
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          color: Color(0xFF77768A),
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
            ),
            if (!readOnly && showClear && controller != null && controller!.text.isNotEmpty)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: const Color(0xFF77768A),
              ),
          ],
        ),
      ),
    );
  }
}
