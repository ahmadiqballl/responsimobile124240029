import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article_model.dart';
import '../services/bookmark_service.dart';

class DetailScreen extends StatefulWidget {
  final Article article;

  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;
  bool _isLoadingFavorite = true;
  bool _isSavingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final isFavorite = await FavoriteService.isFavorite(widget.article.id);
      if (!mounted) return;
      setState(() {
        _isFavorite = isFavorite;
        _isLoadingFavorite = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingFavorite = false);
      _showMessage('Bookmark gagal dimuat: $error', isError: true);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isSavingFavorite) return;
    setState(() => _isSavingFavorite = true);
    try {
      final newStatus = await FavoriteService.toggleFavorite(widget.article);
      if (!mounted) return;
      setState(() => _isFavorite = newStatus);
      _showMessage(
        newStatus
            ? 'Berita ditambahkan ke bookmark.'
            : 'Berita dihapus dari bookmark.',
        isError: !newStatus,
      );
    } catch (error) {
      if (mounted)
        _showMessage('Bookmark gagal diperbarui: $error', isError: true);
    } finally {
      if (mounted) setState(() => _isSavingFavorite = false);
    }
  }

  Future<void> _openFullArticle() async {
    final uri = Uri.tryParse(widget.article.url);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      _showMessage('Tautan artikel tidak valid.', isError: true);
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('Artikel tidak dapat dibuka di browser.', isError: true);
      }
    } catch (error) {
      if (mounted) _showMessage('Artikel gagal dibuka: $error', isError: true);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? const Color.fromARGB(255, 139, 23, 23)
              : Colors.green.shade700,
        ),
      );
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return 'Tanggal tidak tersedia';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          IconButton(
            tooltip: _isFavorite ? 'Hapus bookmark' : 'Simpan bookmark',
            onPressed: _isLoadingFavorite || _isSavingFavorite
                ? null
                : _toggleFavorite,
            icon: _isLoadingFavorite || _isSavingFavorite
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: _isFavorite ? Colors.green : null,
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (article.imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _DetailImageFallback(),
              ),
            )
          else
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: _DetailImageFallback(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.newsSite,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                _MetadataRow(
                  icon: Icons.calendar_today_outlined,
                  text: _formatDate(article.publishedAt),
                ),
                const SizedBox(height: 8),
                _MetadataRow(icon: Icons.person_outline, text: article.authors),
                const SizedBox(height: 20),
                Text(
                  'Ringkasan',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  article.summary.isEmpty
                      ? 'Ringkasan berita tidak tersedia.'
                      : article.summary,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(height: 1.55),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openFullArticle,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Baca Berita Secara Penuh'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetadataRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _DetailImageFallback extends StatelessWidget {
  const _DetailImageFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 52),
      ),
    );
  }
}
