// guard_article.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GuardArticle {
  final String id;
  final String title;
  final String town;
  final int price;
  final int rejectCnt;
  final int approveCnt;
  final String content;
  final String time;

  GuardArticle({
    required this.id, required this.title, required this.town,
    required this.price, required this.rejectCnt, required this.approveCnt,
    required this.content, required this.time,
  });

  factory GuardArticle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GuardArticle(
      id: doc.id,
      title: data['title'] ?? '',
      town: data['town'] ?? '',
      price: data['price'] ?? 0,
      rejectCnt: data['rejectCnt'] ?? 0,
      approveCnt: data['approveCnt'] ?? 0,
      content: data['content'] ?? '',
      time: data['time'] ?? '',
    );
  }
}