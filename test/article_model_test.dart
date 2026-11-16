import 'package:flutter_test/flutter_test.dart';
import 'package:responsi/models/article_model.dart';

void main() {
  test('parses Spaceflight News API fields and author objects', () {
    final article = Article.fromJson({
      'id': 42,
      'title': 'A space story',
      'authors': [
        {'name': 'Author One'},
        {'name': 'Author Two'},
      ],
      'url': 'https://example.com/article',
      'image_url': 'https://example.com/image.jpg',
      'news_site': 'Example News',
      'summary': 'A short summary.',
      'published_at': '2026-11-16T05:00:00Z',
    });

    expect(article.id, 42);
    expect(article.authors, 'Author One, Author Two');
    expect(article.newsSite, 'Example News');
    expect(article.imageUrl, 'https://example.com/image.jpg');
    expect(Article.fromJson(article.toJson()).newsSite, 'Example News');
  });

  test('uses safe defaults when optional fields are absent', () {
    final article = Article.fromJson({'id': 7});

    expect(article.title, 'Tanpa judul');
    expect(article.authors, 'Tidak diketahui');
    expect(article.newsSite, 'Sumber tidak diketahui');
    expect(article.imageUrl, isEmpty);
    expect(article.summary, isEmpty);
  });
}
