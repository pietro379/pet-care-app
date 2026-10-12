import 'package:flutter/material.dart';

import '../models/feed_post.dart';

/// Akış için demo veri kaynağı. Backend gelince içi değişecek.
class FeedRepository {
  Future<List<FeedPost>> getPosts() async {
    const luna = PetAuthor(
      name: 'Luna',
      age: '2',
      breed: 'Golden Retriever',
      color: Color(0xFFD99A3D),
    );
    const pamuk = PetAuthor(
      name: 'Pamuk',
      age: '4',
      breed: 'Van Kedisi',
      color: Color(0xFF6D5BE0),
    );
    const max = PetAuthor(
      name: 'Max',
      age: '1',
      breed: 'Husky',
      color: Color(0xFF2FA89C),
    );
    const misket = PetAuthor(
      name: 'Misket',
      age: '3',
      breed: 'Tekir',
      color: Color(0xFFD9577F),
    );

    return const [
      FeedPost(
        id: 'p1',
        author: luna,
        caption: 'Bugün sahilde harika bir yürüyüş yaptık! 🌊',
        mediaIcon: Icons.beach_access,
        likeCount: 128,
        commentCount: 14,
      ),
      FeedPost(
        id: 'p2',
        author: pamuk,
        caption: 'Güneşli koltuk benim, kimse yaklaşmasın 😼',
        mediaIcon: Icons.wb_sunny,
        likeCount: 342,
        commentCount: 41,
        isVideo: true,
      ),
      FeedPost(
        id: 'p3',
        author: max,
        caption: 'İlk karı gördü, deliye döndü ❄️',
        mediaIcon: Icons.ac_unit,
        likeCount: 87,
        commentCount: 9,
        isVideo: true,
      ),
      FeedPost(
        id: 'p4',
        author: misket,
        caption: 'Yeni oyuncağımı çok sevdim, ama kutusunu daha çok 📦',
        mediaIcon: Icons.inventory_2,
        likeCount: 215,
        commentCount: 22,
      ),
    ];
  }
}
