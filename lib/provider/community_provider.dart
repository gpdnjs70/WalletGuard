// community_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:midterm_project/models/community_post.dart';

class CommunityProvider extends ChangeNotifier {
  List<CommunityPost> _posts = [];
  List<CommunityPost> get posts => _posts;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CommunityProvider() {
    _listenToPosts();
  }

  // Firestore의 데이터를 실시간으로 수신
  void _listenToPosts() {
    _db.collection('community_posts')
        .orderBy('createdAt', descending: true) // 최신 글이 위로 오도록 정렬
        .snapshots()
        .listen((snapshot) {
      _posts = snapshot.docs.map((doc) => CommunityPost.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  // 새 글 등록 (Firestore에 저장)
  Future<void> addPost(String tag, String title, String content) async {
    await _db.collection('community_posts').add({
      'tag': tag,
      'title': title,
      'content': content,
      'user': "지갑수호대장", // 추후 로그인 유저 정보로 변경
      'town': "삼성동",
      'time': "방금 전",
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(), // 정렬을 위한 타임스탬프
    });
  }

  // 공감(추천) 기능 (Firestore 문서 업데이트)
  Future<void> likePost(String id) async {
    await _db.collection('community_posts').doc(id).update({
      'likes': FieldValue.increment(1) // 기존 값에서 1 증가
    });
  }

  // 특정 동네생활 게시글의 댓글 실시간 가져오기
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _db
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // 특정 동네생활 게시글에 댓글 작성하기
  Future<void> addComment(String postId, String content) async {
    await _db
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .add({
      'user': '지갑수호대장', // 실제 유저명으로 나중에 변경
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 내가 쓴 게시글 스트림
  Stream<QuerySnapshot> getMyPostsStream() {
    return _db.collection('community_posts')
        .where('user', isEqualTo: '지갑수호대장')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}