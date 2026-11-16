import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/article_model.dart';

class FavoriteService {
  static const String keyFavorites = 'favorite_articles';

  static Future<List<Article>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favList = prefs.getStringList(keyFavorites);
    if (favList == null) return [];

    return favList.map((item) => Article.fromJson(jsonDecode(item))).toList();
  }

  static Future<bool> isFavorite(int articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favList = prefs.getStringList(keyFavorites);
    if (favList == null) return false;

    return favList.any((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == articleId;
    });
  }

  static Future<bool> toggleFavorite(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favList = prefs.getStringList(keyFavorites) ?? [];

    final index = favList.indexWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == article.id;
    });

    if (index >= 0) {
      favList.removeAt(index);
      await prefs.setStringList(keyFavorites, favList);
      return false; // Sekarang tidak favorit
    } else {
      favList.add(jsonEncode(article.toJson()));
      await prefs.setStringList(keyFavorites, favList);
      return true; // Sekarang menjadi favorit
    }
  }

  /// Menghapus artikel dari daftar favorit berdasarkan ID artikel
  static Future<void> removeFavorite(int articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favList = prefs.getStringList(keyFavorites) ?? [];

    favList.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == articleId;
    });

    await prefs.setStringList(keyFavorites, favList);
  }
}
