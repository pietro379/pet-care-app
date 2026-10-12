import 'dart:async';

import 'package:flutter/material.dart';

import '../models/feed_post.dart';
import '../utils/date_format.dart';

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isMine,
    required this.sentAt,
  });

  final String text;
  final bool isMine;
  final DateTime sentAt;
}

/// WhatsApp benzeri sohbet ekranı. Giden mesajlar sağda, gelenler solda.
/// Backend olmadığı için karşı taraf demo olarak otomatik yanıt verir.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.peer});

  final PetAuthor peer;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  Timer? _replyTimer;

  static const _demoReplies = [
    'Merhaba! 🐾',
    'Tanıştığımıza çok memnun oldum!',
    'Bir ara parkta buluşalım mı?',
    'Harika fikir, ben de çok isterim 😊',
  ];
  int _replyIndex = 0;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text: 'Selam! Ben ${widget.peer.name} 👋',
        isMine: false,
        sentAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(text: text, isMine: true, sentAt: DateTime.now()),
      );
    });
    _controller.clear();

    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(seconds: 1, milliseconds: 200), () {
      if (!mounted) return;
      final reply = _demoReplies[_replyIndex % _demoReplies.length];
      _replyIndex++;
      setState(() {
        _messages.add(
          _ChatMessage(text: reply, isMine: false, sentAt: DateTime.now()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final peer = widget.peer;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: peer.color,
              child: const Icon(Icons.pets, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(peer.name, style: theme.textTheme.titleMedium),
                Text(
                  'çevrimiçi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              // reverse: yeni mesaj eklenince liste otomatik en alta yapışır.
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final message = _messages[_messages.length - 1 - i];
                return _MessageBubble(message: message);
              },
            ),
          ),
          _MessageInput(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = message.isMine;
    // Giden mesajlar ana renkte, gelenler nötr yüzeyde.
    final background = mine
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHigh;
    final foreground = mine
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 4),
              bottomRight: Radius.circular(mine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatTime(message.sentAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Gönder',
              onPressed: onSend,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
