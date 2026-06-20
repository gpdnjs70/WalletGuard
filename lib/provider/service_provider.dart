// service_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:midterm_project/models/guard_article.dart';

class ServiceProvider extends ChangeNotifier {
  List<GuardArticle> _articles = [];
  List<GuardArticle> get articles => _articles;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ServiceProvider() {
    _listenToArticles();
  }

  // Firestore의 데이터를 실시간으로 수신
  void _listenToArticles() {
    _db.collection('guard_articles')
        .orderBy('createdAt', descending: true) // 최신 글이 위로 오도록 정렬
        .snapshots()
        .listen((snapshot) {
      _articles = snapshot.docs.map((doc) => GuardArticle.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  // 글쓰기 기능 (Firestore에 저장)
  Future<void> addArticle(String title, String price, String content) async {
    try {
      await _db.collection('guard_articles').add({
        'title': title,
        'town': "삼성동",
        'price': int.parse(price),
        'rejectCnt': 0,
        'approveCnt': 0,
        'content': content,
        'time': "방금 전",
        'createdAt': FieldValue.serverTimestamp(),
        'user': '지갑수호대장', // 👈 이 필드가 꼭 있어야 합니다.
      });
      print("Firestore 데이터 저장 성공!"); // 👈 콘솔 확인용
    } catch (e) {
      print("저장 실패: $e"); // 👈 에러 발생 시 여기로 뜹니다.
    }
  }

  // 투표 기능 (Firestore 문서 업데이트)
  Future<void> vote(String id, bool isApprove) async {
    final docRef = _db.collection('guard_articles').doc(id);

    if (isApprove) {
      await docRef.update({'approveCnt': FieldValue.increment(1)});
    } else {
      await docRef.update({'rejectCnt': FieldValue.increment(1)});
    }
  }

  // 1. 특정 게시글의 실시간 댓글 스트림(Stream) 가져오기
  Stream<QuerySnapshot> getCommentsStream(String articleId) {
    return _db
        .collection('guard_articles')
        .doc(articleId)
        .collection('comments')
        .orderBy('createdAt', descending: false) // 오래된 댓글이 위로 오도록 정렬
        .snapshots();
  }

  // 2. 특정 게시글에 댓글 작성하기
  Future<void> addComment(String articleId, String content) async {
    await _db
        .collection('guard_articles')
        .doc(articleId)
        .collection('comments')
        .add({
      'user': '지갑수호대장', // 나중에는 실제 유저명으로 변경
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 내 심판 내역(수호 요청) 스트림
  Stream<QuerySnapshot> getMyArticlesStream() {
    return _db.collection('guard_articles')
        .where('user', isEqualTo: '지갑수호대장') // 실제 로그인된 유저명 사용
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  // 현재 선택된 인덱스를 가져오는 변수
  int get currentNavigationIndex => _currentIndex;

  // 페이지를 변경하고 화면을 새로고침하는 함수
  void updatePage(int index) {
    _currentIndex = index;
    notifyListeners(); // 이 코드가 있어야 화면이 바뀝니다.
  }
}