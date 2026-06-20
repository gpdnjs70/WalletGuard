// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:midterm_project/App.dart';
import 'package:midterm_project/provider/service_provider.dart';
import 'package:provider/provider.dart';
import 'package:midterm_project/provider/community_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 실행 환경이 웹(크롬)인지 확인합니다.
  if (kIsWeb) {
    // 웹 환경: Firebase 콘솔에서 복사한 값을 여기에 붙여넣습니다.
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyB4lulE5jY1ycYO7b3icE57pVztBsmzc8E",
          authDomain: "wallet-guard-5154b.firebaseapp.com",
          projectId: "wallet-guard-5154b",
          storageBucket: "wallet-guard-5154b.firebasestorage.app",
          messagingSenderId: "588879967074",
          appId: "1:588879967074:web:a03a0f8c9322005c5eb23b"
      ),
    );
  } else {
    // 안드로이드 환경: 기존처럼 google-services.json을 읽도록 합니다.
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: const WalletGuardApp(),
    ),
  );
}

class WalletGuardApp extends StatelessWidget {
  const WalletGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFD541),
        scaffoldBackgroundColor: const Color(0xFFFFD541),
      ),
      // builder를 사용하여 모든 화면을 비율로 감쌉니다.
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: AspectRatio(
              aspectRatio: 9 / 16, // 세로형 비율
              child: child, // 여기에 실제 앱 화면들이 들어갑니다.
            ),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}

class AddArticleView extends StatefulWidget {
  const AddArticleView({super.key});
  @override
  State<AddArticleView> createState() => _AddArticleViewState();
}

class _AddArticleViewState extends State<AddArticleView> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _contentController = TextEditingController();

  final Color brandYellow = const Color(0xFFFFD541);
  final Color darkText = const Color(0xFF1A1A1A);
  final Color softGray = const Color(0xFFF9FAFB);
  final Color accentRed = const Color(0xFFFF4B4B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandYellow, // 전체 배경은 노란색
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: Icon(Icons.close_rounded, color: darkText, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                print("완료 버튼 클릭됨!");
                if (_titleController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                  Provider.of<ServiceProvider>(context, listen: false).addArticle(
                    _titleController.text,
                    _priceController.text,
                    _contentController.text,
                  );
                  print("addArticle 함수 호출됨!");
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkText,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: const Text("완료", style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. 헤더 영역 (고정)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 10, 28, 30), // 하단 여백을 조금 더 줌
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "텅장을 지키기 위한",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText.withOpacity(0.6)),
                ),
                const SizedBox(height: 4),
                Text(
                  "탕진 심판 신청",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: darkText, letterSpacing: -1.0),
                ),
              ],
            ),
          ),

          // 2. 입력 컨테이너 (스크롤 영역)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: softGray,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(44),
                  topRight: Radius.circular(44),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              // 스크롤 시 라운드 경계 안쪽에서 내용이 잘리도록 Clip 적용
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(44),
                  topRight: Radius.circular(44),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  child: Column(
                    children: [
                      _buildDesignCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel("무엇을 구매하실 건가요?"),
                            TextField(
                              controller: _titleController,
                              cursorColor: brandYellow,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: darkText),
                              decoration: _buildInputDecoration("구매 예정 물품 입력"),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                            ),
                            _buildSectionLabel("예상 탕진 금액"),
                            Row(
                              children: [
                                // ₩ 기호 색상을 검은색(darkText)으로 변경
                                Text("₩", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: darkText)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    cursorColor: accentRed,
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: accentRed),
                                    decoration: _buildInputDecoration("0"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDesignCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel("고민되는 이유를 적어주세요"),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _contentController,
                              maxLines: 8,
                              cursorColor: brandYellow,
                              style: TextStyle(fontSize: 16, height: 1.6, color: darkText.withOpacity(0.8)),
                              decoration: _buildInputDecoration("왜 사고 싶은지, 왜 참아야 하는지 적어주세요."),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 나머지 헬퍼 위젯들(Label, Decoration, Card)은 이전과 동일하게 유지
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: darkText.withOpacity(0.4), letterSpacing: 0.5),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: darkText.withOpacity(0.2), fontWeight: FontWeight.w500),
      border: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildDesignCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}