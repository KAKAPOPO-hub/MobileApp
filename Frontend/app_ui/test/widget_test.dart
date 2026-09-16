// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:app_ui/pages/post.dart';
import 'package:app_ui/pages/post_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Post detail page shows the full post content', (tester) async {
    const post = Post(
      id: 7,
      userId: 3,
      title: 'Judul postingan',
      content:
          'Ini adalah isi lengkap dari postingan yang ingin dibaca.\nKontennya bisa lebih panjang dan terlihat jelas di halaman detail.',
      author: PostAuthor(id: 3, username: 'alice'),
      createdAt: null,
      updatedAt: null,
      imageUrl: null,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PostDetailPage(post: post),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('@alice'), findsOneWidget);
    expect(find.text('Judul postingan'), findsOneWidget);
    expect(find.textContaining('Ini adalah isi lengkap'), findsOneWidget);
  });
}
