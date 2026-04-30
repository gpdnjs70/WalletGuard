import 'package:flutter/material.dart';
import 'package:midterm_project/App.dart';
import 'package:midterm_project/provider/service_provider.dart';
import 'package:provider/provider.dart';
import 'package:midterm_project/provider/community_provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ChangeNotifierProvider(create: (_) => CommunityProvider()),
    ],
    child: const WalletGuardApp(),
  ));
}

class WalletGuardApp extends StatelessWidget {
  const WalletGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFD700),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainNavigationPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F6), // 앱 전체 배경색과 통일
      appBar: AppBar(
        title: const Text("수호 요청 글쓰기", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                Provider.of<ServiceProvider>(context, listen: false).addArticle(
                  _titleController.text,
                  _priceController.text,
                  _contentController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("완료", style: TextStyle(color: Color(0xfff08f4f), fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView( // 키보드 올라올 때 대비
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "제목",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF868B94)),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 30, color: Color(0xFFF2F3F6)),

              // 가격 입력
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "가격(원)",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.sell_outlined, size: 20, color: Color(0xFF4D5159)),
                  hintStyle: TextStyle(color: Color(0xFF868B94)),
                ),
              ),
              const SizedBox(height: 10),

              // 내용 입력
              TextField(
                controller: _contentController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: "수호대원들에게 수호가 필요한 이유를 설득해 보세요!",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF868B94), fontSize: 15),
                ),
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}