import 'dart:convert';
import 'dart:io';

import '../models/article_model.dart';

/// Loads articles from the Spaceflight News API.
class ApiService {
  static const String _baseUrl =
      'https://api.spaceflightnewsapi.net/v4/articles/';

  /// Loads up to 30 recent articles, optionally filtered by news site.
  static Future<List<Article>> getNews({String? newsSite}) async {
    final queryParams = <String, String>{'limit': '30'};
    if (newsSite != null && newsSite.isNotEmpty) {
      queryParams['news_site'] = newsSite;
    }

    final data = await _getJson(
      Uri.parse(_baseUrl).replace(queryParameters: queryParams),
    );
    final results = data['results'];
    if (results is! List) {
      throw const FormatException('Respons daftar berita tidak valid.');
    }

    return results.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Data berita pada respons tidak valid.');
      }
      return Article.fromJson(item);
    }).toList();
  }

  /// Loads a single article by its API ID.
  static Future<Article> getArticleDetail(int id) async {
    final data = await _getJson(Uri.parse('$_baseUrl$id/'));
    return Article.fromJson(data);
  }

  static Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 20));
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Permintaan berita gagal (HTTP ${response.statusCode}).',
          uri: uri,
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respons berita tidak valid.');
      }
      return decoded;
    } finally {
      client.close();
    }
  }
}
