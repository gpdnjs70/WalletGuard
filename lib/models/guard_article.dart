// lib/models/guard_article.dart
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
}