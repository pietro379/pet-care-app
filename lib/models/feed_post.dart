import 'package:flutter/material.dart';

/// Akıştaki gönderiyi paylaşan evcil hayvanın herkese açık profili.
class PetAuthor {
  const PetAuthor({
    required this.name,
    required this.age,
    required this.breed,
    required this.color,
  });

  final String name;
  final String age;
  final String breed;

  /// Avatar ve demo görseller için tema rengi.
  final Color color;
}

/// Akıştaki tek bir gönderi.
class FeedPost {
  const FeedPost({
    required this.id,
    required this.author,
    required this.caption,
    required this.mediaIcon,
    required this.likeCount,
    required this.commentCount,
    this.isVideo = false,
  });

  final String id;
  final PetAuthor author;
  final String caption;

  /// Gerçek fotoğraf/video yüklemesi gelene kadar demo görselde gösterilen ikon.
  final IconData mediaIcon;
  final int likeCount;
  final int commentCount;
  final bool isVideo;
}
