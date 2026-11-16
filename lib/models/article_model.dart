class Article {
  final int id;
  final String title;
  final String authors;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;

  const Article({
    required this.id,
    required this.title,
    required this.authors,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final authorsValue = json['authors'];
    final authors = switch (authorsValue) {
      List<dynamic> values => values
          .map((author) {
            if (author is Map<String, dynamic>) {
              return author['name']?.toString() ?? '';
            }
            return author.toString();
          })
          .where((name) => name.isNotEmpty)
          .join(', '),
      String value => value,
      _ => '',
    };

    return Article(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? 'Tanpa judul',
      authors: authors.isEmpty ? 'Tidak diketahui' : authors,
      url: json['url']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      newsSite:
          (json['news_site'] ?? json['new_site'])?.toString() ??
          'Sumber tidak diketahui',
      summary: json['summary']?.toString() ?? '',
      publishedAt: json['published_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt,
    };
  }
}
