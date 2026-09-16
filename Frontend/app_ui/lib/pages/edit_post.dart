import 'package:flutter/material.dart';

import 'post.dart';
import '../services/post_service.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({super.key, required this.post});

  final Post post;

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  static const _categories = <DropdownMenuItem<int>>[
    DropdownMenuItem(value: 1, child: Text('Puisi')),
    DropdownMenuItem(value: 2, child: Text('Pantun')),
    DropdownMenuItem(value: 3, child: Text('Sajak')),
    DropdownMenuItem(value: 4, child: Text('Cerpen')),
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _saving = false;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _categoryId = widget.post.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.length < 3 || content.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul atau isi post belum valid')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await const PostService().updatePost(
        postId: widget.post.id,
        title: title,
        content: content,
        categoryId: _categoryId,
      );
      if (mounted) Navigator.pop(context, true);
    } on PostServiceException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Simpan perubahan',
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul post'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: _categories,
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Isi post',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
