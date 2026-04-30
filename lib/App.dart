import 'package:flutter/material.dart';
import 'package:midterm_project/provider/service_provider.dart';
import 'package:midterm_project/main.dart';
import 'package:provider/provider.dart';
import 'package:midterm_project/models/community_post.dart';
import 'package:midterm_project/provider/community_provider.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);
    final currentIndex = nav.currentNavigationIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F6),
      body: IndexedStack(
        index: currentIndex,
        children: const [HomeView(), CommunityView(), MyCarrotView()],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => nav.updatePage(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF868B94),
          backgroundColor: Colors.white,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: '동네생활'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '나의 수호'),
          ],
        ),
      ),
      floatingActionButton: currentIndex == 2
          ? null
          : FloatingActionButton(
        elevation: 3,
        highlightElevation: 5,
        backgroundColor: const Color(0xFFFFD700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          if (currentIndex == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddArticleView()));
          } else if (currentIndex == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCommunityPostView()));
          }
        },
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F6), // 연한 회색 배경으로 카드 부각
      appBar: AppBar(
        title: const Text("수호 요청 목록", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, service, child) {
          if (service.articles.isEmpty) {
            return const Center(child: Text("등록된 수호 요청이 없습니다."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: service.articles.length,
            itemBuilder: (context, index) {
              final item = service.articles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(item.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("${item.town} · ${item.price}원", style: const TextStyle(color: Color(0xFF868B94), fontSize: 13)),
                    const SizedBox(height: 12),
                    Text(item.content, style: const TextStyle(fontSize: 15, color: Color(0xFF4D5159), height: 1.4)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildVoteBtn(Icons.block, "기각", item.rejectCnt, Colors.redAccent, () => service.vote(item.id, false)),
                        const SizedBox(width: 12),
                        _buildVoteBtn(Icons.check_circle_outline, "승인", item.approveCnt, Colors.green, () => service.vote(item.id, true)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVoteBtn(IconData icon, String label, int count, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text("$label $count", style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  String selectedCategory = "전체";

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final filteredPosts = selectedCategory == "전체"
            ? provider.posts
            : provider.posts.where((post) => post.tag == selectedCategory).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF2F3F6), // 홈과 동일한 배경색
          appBar: AppBar(
            title: const Text("동네생활", style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ],
          ),
          body: Column(
            children: [
              // 카테고리 칩 영역 (흰색 배경 유지)
              Container(
                color: const Color(0xFFF2F3F6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: ["전체", "절약꿀팁", "동네질문", "가계부공유", "수호성공"]
                        .map((label) => _categoryChip(label))
                        .toList(),
                  ),
                ),
              ),
              // 리스트 영역
              Expanded(
                child: filteredPosts.isEmpty
                    ? const Center(child: Text("해당 카테고리에 글이 없습니다."))
                    : ListView.builder(
                  padding: const EdgeInsets.all(12), // 홈과 동일한 패딩
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    return _buildPostItem(filteredPosts[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _categoryChip(String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          // 선택 시 노란색, 미선택 시 흰색으로 수정하여 바탕색(회색)과 구분
          color: isSelected ? const Color(0xFFFFD700) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.black : const Color(0xFF868B94),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(CommunityPost post) {
    return Container(
      margin: const Offset(0, 0) == const Offset(0, 0) ? const EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailView(post: post)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(post.tag, style: const TextStyle(fontSize: 11, color: Color(0xFF666B77), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text("${post.user} · ${post.town}", style: const TextStyle(fontSize: 13, color: Color(0xFF868B94))),
                  const Spacer(),
                  Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(post.likes.toString(), style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyCarrotView extends StatelessWidget {
  const MyCarrotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F6), // 전체 배경색 통일
      appBar: AppBar(
        title: const Text("나의 수호", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 프로필 영역 (상단 고정 카드 스타일)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFFFD700),
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("지갑 수호대장", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("삼성동 #12345", style: TextStyle(color: Color(0xFF868B94), fontSize: 14)),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD1D3D9)),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text("프로필 수정", style: TextStyle(color: Colors.black, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. 수호 통계 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat("기각시킨 지름", "12건", Colors.redAccent),
                    Container(width: 1, height: 30, color: const Color(0xFFF2F3F6)),
                    _buildStat("수호한 금액", "34만원", Colors.green),
                    Container(width: 1, height: 30, color: const Color(0xFFF2F3F6)),
                    _buildStat("수호 온도", "37.5℃", const Color(0xFFFFD700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. 메뉴 리스트 (각 항목을 개별 카드로 분리하여 UI 통일)
            _buildMenuCard(context, Icons.list_alt, "나의 수호 요청 히스토리"),
            _buildMenuCard(context, Icons.article_outlined, "내가 쓴 동네생활 글"),
            _buildMenuCard(context, Icons.favorite_border, "관심 있는 절약 정보"),
            _buildMenuCard(context, Icons.storefront_outlined, "비즈프로필 관리"),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(thickness: 1, color: Color(0xFFE9ECEF), indent: 20, endIndent: 20),
            ),

            _buildMenuCard(context, Icons.announcement_outlined, "공지사항"),
            _buildMenuCard(context, Icons.help_outline, "자주 묻는 질문"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF868B94))),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // 홈 화면 카드 스타일을 적용한 새로운 메뉴 타일 함수
  Widget _buildMenuCard(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF868B94)),
          onTap: () {
            // 클릭 시 페이지 이동 로직
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: const Color(0xFFF2F3F6),
                  appBar: AppBar(
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  body: Center(child: Text("$title 페이지가 준비 중입니다.", style: const TextStyle(color: Color(0xFF868B94)))),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AddCommunityPostView extends StatefulWidget {
  const AddCommunityPostView({super.key});

  @override
  State<AddCommunityPostView> createState() => _AddCommunityPostViewState();
}

class _AddCommunityPostViewState extends State<AddCommunityPostView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String selectedTag = "동네질문";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F6), // 배경색 통일
      appBar: AppBar(
        title: const Text("동네생활 글쓰기", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                Provider.of<CommunityProvider>(context, listen: false).addPost(
                  selectedTag, _titleController.text, _contentController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("완료", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 태그 선택 섹션
              const Text("카테고리 선택", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedTag,
                isExpanded: true,
                underline: const SizedBox(), // 밑줄 제거
                items: ["절약꿀팁", "동네질문", "가계부공유", "수호성공"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => selectedTag = v!),
              ),
              const Divider(height: 30),
              // 제목 입력
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "제목", border: InputBorder.none),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // 내용 입력
              TextField(
                controller: _contentController,
                maxLines: 12,
                decoration: const InputDecoration(hintText: "동네 분들과 나누고 싶은 이야기를 적어주세요.", border: InputBorder.none),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityDetailView extends StatelessWidget {
  final CommunityPost post;
  const CommunityDetailView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final currentPost = provider.posts.firstWhere((p) => p.id == post.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF2F3F6), // 배경색 통일
          appBar: AppBar(
            title: const Text("동네생활", style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF2F3F6), borderRadius: BorderRadius.circular(4)),
                    child: Text(currentPost.tag, style: const TextStyle(color: Color(0xFF666B77), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text(currentPost.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),
                  const SizedBox(height: 8),
                  Text("${currentPost.user} · ${currentPost.town} · ${currentPost.time}", style: const TextStyle(color: Color(0xFF868B94), fontSize: 13)),
                  const Divider(height: 40, color: Color(0xFFF2F3F6)),
                  Text(currentPost.content, style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF4D5159))),
                  const SizedBox(height: 40),
                  // 추천 버튼을 당근마켓 스타일의 버튼으로 변경
                  Center(
                    child: InkWell(
                      onTap: () => provider.likePost(currentPost.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.thumb_up_outlined, size: 18, color: Color(0xFFF08F4F)),
                            const SizedBox(width: 8),
                            Text(
                              "이 글이 도움이 됐어요 ${currentPost.likes}",
                              style: const TextStyle(color: Color(0xFFF08F4F), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}