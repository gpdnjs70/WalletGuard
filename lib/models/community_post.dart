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
}