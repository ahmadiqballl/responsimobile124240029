import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../services/bookmark_service.dart';
import 'detail_screen.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BookmarkList();
  }
}

class _BookmarkList extends StatefulWidget {
  const _BookmarkList();

  @override
  State<_BookmarkList> createState() => _BookmarkListState();
}

class _BookmarkListState extends State<_BookmarkList> {
  late Future<List<Article>> _favorites;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _favorites = FavoriteService.getFavorites();
  }

  Future<void> _removeFavorite(Article article) async {
    try {
      await FavoriteService.removeFavorite(article.id);
      if (!mounted) return;
      setState(_loadFavorites);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Berita dihapus dari bookmark.'),
            backgroundColor: const Color.fromARGB(255, 139, 23, 23),
          ),
        );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bookmark gagal dihapus: $error'),
          backgroundColor: const Color.fromARGB(255, 139, 23, 23),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: _favorites,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Bookmark gagal dimuat: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => setState(_loadFavorites),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 56),
                  SizedBox(height: 12),
                  Text('Belum ada berita yang disimpan.'),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return Dismissible(
              key: ValueKey(article.id),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.only(right: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 139, 23, 23),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) => _removeFavorite(article),
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: article.imageUrl.isEmpty
                      ? const SizedBox(
                          width: 72,
                          height: 72,
                          child: Icon(Icons.image_not_supported_outlined),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            article.imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox(
                              width: 72,
                              height: 72,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                  title: Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(article.newsSite),
                  ),
                  onTap: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => DetailScreen(article: article),
                      ),
                    );
                    if (mounted) setState(_loadFavorites);
                  },
                  trailing: IconButton(
                    tooltip: 'Hapus bookmark',
                    onPressed: () => _removeFavorite(article),
                    icon: const Icon(Icons.bookmark_remove_outlined),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
