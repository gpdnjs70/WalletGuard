// community_post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String tag;
  final String title;
  final String content;
  final String user;
  final String town;
  final String time;
  int likes;

  CommunityPost({
    required this.id, required this.tag, required this.title,
    required this.content, required this.user, required this.town,
    required this.time, required this.likes,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      tag: data['tag'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      user: data['user'] ?? '알 수 없음',
      town: data['town'] ?? '',
      time: data['time'] ?? '',
      likes: data['likes'] ?? 0,
    );
  }
}