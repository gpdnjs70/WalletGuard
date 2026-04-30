import 'package:flutter/material.dart';
import 'package:midterm_project/models/community_post.dart';

class CommunityProvider extends ChangeNotifier {
  final List<CommunityPost> _posts = [
    CommunityPost(id: "1", tag: "절약꿀팁", title: "편의점 1+1 행사 활용법", content: "내용...", user: "수호단장", town: "삼성동", time: "1시간 전", likes: 12),
  ];

  List<CommunityPost> get posts => _posts;

  // 새 글 등록
  void addPost(String tag, String title, String content) {
    final newPost = CommunityPost(
      id: DateTime.now().toString(),
      tag: tag,
      title: title,
      content: content,
      user: "지갑수호대장", // 로그인 유저 정보
      town: "삼성동",
      time: "방금 전",
      likes: 0,
    );
    _posts.insert(0, newPost);
    notifyListeners();
  }

  // 공감(추천) 기능
  void likePost(String id) {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      _posts[index].likes++;
      notifyListeners();
    }
  }
}