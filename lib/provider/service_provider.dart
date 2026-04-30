// lib/provider/service_provider.dart
import 'package:flutter/material.dart';
import 'package:midterm_project/models/guard_article.dart';

class ServiceProvider extends ChangeNotifier {
  // 실제 앱이라면 서버에서 받아올 데이터 리스트
  List<GuardArticle> _articles = [
    GuardArticle(id: "1", title: "아이패드 프로 사도 될까요?", town: "삼성동", price: 1200000, rejectCnt: 15, approveCnt: 2, content: "공부할 때 쓰려는데 너무 비싸네요.", time: "방금 전"),
    GuardArticle(id: "2", title: "야식 족발 지를까요?", town: "논현동", price: 38000, rejectCnt: 40, approveCnt: 1, content: "배고픈데 참아야겠죠?", time: "5분 전"),
  ];

  List<GuardArticle> get articles => _articles;

  // 글쓰기 기능 (진짜로 리스트에 추가됨)
  void addArticle(String title, String price, String content) {
    final newArticle = GuardArticle(
      id: DateTime.now().toString(),
      title: title,
      town: "삼성동", // 유저 정보에서 가져올 부분
      price: int.parse(price),
      rejectCnt: 0,
      approveCnt: 0,
      content: content,
      time: "방금 전",
    );
    _articles.insert(0, newArticle);
    notifyListeners();
  }

  // 투표 기능
  void vote(String id, bool isApprove) {
    // 리스트에서 해당 ID를 가진 게시글 찾기
    int index = _articles.indexWhere((article) => article.id == id);

    if (index != -1) {
      GuardArticle old = _articles[index];

      // 기존 데이터를 바탕으로 숫자가 업데이트된 새 객체 생성 (데이터 불변성 유지)
      _articles[index] = GuardArticle(
        id: old.id,
        title: old.title,
        town: old.town,
        price: old.price,
        content: old.content,
        time: old.time,
        rejectCnt: isApprove ? old.rejectCnt : old.rejectCnt + 1,
        approveCnt: isApprove ? old.approveCnt + 1 : old.approveCnt,
      );

      notifyListeners(); // 중요: 이걸 호출해야 HomeView의 Consumer가 반응함
    }
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