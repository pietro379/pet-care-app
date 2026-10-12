import 'package:flutter/material.dart';

import '../../models/feed_post.dart';
import '../../services/feed_repository.dart';
import '../chat_screen.dart';

/// Akış sekmesi: dikey kaydırılan gönderi listesi.
class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final _repository = FeedRepository();
  late Future<List<FeedPost>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getPosts();
  }

  Future<void> _refresh() async {
    final next = _repository.getPosts();
    setState(() {
      _future = next;
    });
    await next;
  }

  void _showAuthorPreview(PetAuthor author) {
    // Sheet kapandıktan sonra sohbete geçmek için kök navigator'ı kullanıyoruz.
    final navigator = Navigator.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _PetPreviewSheet(
        author: author,
        onMessage: () {
          Navigator.of(sheetContext).pop();
          navigator.push(
            MaterialPageRoute(builder: (_) => ChatScreen(peer: author)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<FeedPost>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final posts = snapshot.data ?? const [];
          if (posts.isEmpty) {
            return const Center(child: Text('Henüz gönderi yok.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              separatorBuilder: (_, _) => Container(
                height: 3,
                margin: const EdgeInsets.symmetric(vertical: 16),
                // Gönderileri ayıran ince şerit: uçlara doğru yumuşakça solar
                // (açık/koyu temada çalışır).
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.withValues(alpha: 0),
                      Colors.grey.withValues(alpha: 0.4),
                      Colors.grey.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              itemBuilder: (context, i) => _PostCard(
                post: posts[i],
                onAuthorTap: () => _showAuthorPreview(posts[i].author),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({required this.post, required this.onAuthorTap});

  final FeedPost post;
  final VoidCallback onAuthorTap;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;

  void _showSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature çok yakında')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final author = post.author;
    final likes = post.likeCount + (_liked ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık: avatar + isim (tıklanınca ön gösterim profili açılır)
        InkWell(
          onTap: widget.onAuthorTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: author.color,
                  child: const Icon(Icons.pets, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(author.breed, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),
        ),
        // Gönderi görseli / videosu (demo)
        AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onDoubleTap: () => setState(() => _liked = true),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [author.color.withValues(alpha: 0.35), author.color],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    post.mediaIcon,
                    size: 110,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  if (post.isVideo)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  if (post.isVideo)
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(Icons.videocam, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Aksiyonlar: Beğen, Yorum Yap, Paylaş
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Beğen',
                onPressed: () => setState(() => _liked = !_liked),
                icon: Icon(
                  _liked ? Icons.favorite : Icons.favorite_border,
                  color: _liked ? Colors.red : null,
                ),
              ),
              IconButton(
                tooltip: 'Yorum Yap',
                onPressed: () => _showSoon('Yorumlar'),
                icon: const Icon(Icons.mode_comment_outlined),
              ),
              IconButton(
                tooltip: 'Paylaş',
                onPressed: () => _showSoon('Paylaşım'),
                icon: const Icon(Icons.send_outlined),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$likes beğeni',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${author.name} ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: post.caption),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${post.commentCount} yorumun tümünü gör',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Avatar/isme tıklanınca açılan küçük profil önizlemesi.
class _PetPreviewSheet extends StatelessWidget {
  const _PetPreviewSheet({required this.author, required this.onMessage});

  final PetAuthor author;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: author.color,
              child: const Icon(Icons.pets, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              author.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoChip(
                  icon: Icons.cake_outlined,
                  label: '${author.age} yaş',
                ),
                const SizedBox(width: 10),
                _InfoChip(icon: Icons.category_outlined, label: author.breed),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onMessage,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Mesaj Gönder'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
