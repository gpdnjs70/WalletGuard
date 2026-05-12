import 'package:flutter/material.dart';
import 'package:midterm_project/provider/service_provider.dart';
import 'package:midterm_project/main.dart';
import 'package:provider/provider.dart';
import 'package:midterm_project/models/community_post.dart';
import 'package:midterm_project/provider/community_provider.dart';

// 공통 디자인 상수
const Color brandYellow = Color(0xFFFFD541);
const Color darkText = Color(0xFF1A1A1A);
const Color softGray = Color(0xFFF9FAFB);
const Color accentRed = Color(0xFFFF4B4B);

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);
    final currentIndex = nav.currentNavigationIndex;

    return Scaffold(
      backgroundColor: brandYellow,
      body: SafeArea(
        bottom: false,
        // 상단 탑바와 헤더 텍스트 사이의 간격을 확보하기 위해 Padding 추가
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: IndexedStack(
            index: currentIndex,
            children: const [HomeView(), CommunityView(), MyCarrotView()],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => nav.updatePage(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: darkText,
          unselectedItemColor: const Color(0xFFADB5BD),
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: '수호'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: '동네생활'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '나의 수호'),
          ],
        ),
      ),
      floatingActionButton: currentIndex == 2
          ? null
          : FloatingActionButton(
        elevation: 4,
        backgroundColor: darkText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          if (currentIndex == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddArticleView()));
          } else if (currentIndex == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCommunityPostView()));
          }
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader("함께 지키는", "수호 요청 목록"),
        Expanded(
          child: _buildWhiteContainer(
            child: Consumer<ServiceProvider>(
              builder: (context, service, child) {
                if (service.articles.isEmpty) {
                  return const Center(child: Text("등록된 수호 요청이 없습니다."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: service.articles.length,
                  itemBuilder: (context, index) {
                    final item = service.articles[index];
                    return _buildServiceCard(item, service);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(item, service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.town, style: TextStyle(color: darkText.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold)),
              Text(item.time, style: TextStyle(color: darkText.withOpacity(0.3), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: darkText)),
          const SizedBox(height: 4),
          Text("₩${item.price}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: accentRed)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: softGray, thickness: 2),
          ),
          Text(item.content, style: TextStyle(fontSize: 14, color: darkText.withOpacity(0.7), height: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildVoteBtn(Icons.close_rounded, "기각", item.rejectCnt, Colors.grey, () => service.vote(item.id, false))),
              const SizedBox(width: 10),
              Expanded(child: _buildVoteBtn(Icons.check_rounded, "승인", item.approveCnt, brandYellow, () => service.vote(item.id, true))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteBtn(IconData icon, String label, int count, Color color, VoidCallback onTap) {
    bool isYellow = color == brandYellow;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isYellow ? brandYellow : softGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: darkText),
            const SizedBox(width: 6),
            Text("$label $count", style: const TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 13)),
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
    return Column(
      children: [
        _buildHeader("따뜻한 소통", "동네생활"),
        Expanded(
          child: _buildWhiteContainer(
            child: Consumer<CommunityProvider>(
              builder: (context, provider, child) {
                final filteredPosts = selectedCategory == "전체"
                    ? provider.posts
                    : provider.posts.where((post) => post.tag == selectedCategory).toList();

                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Row(
                        children: ["전체", "절약꿀팁", "동네질문", "가계부공유", "수호성공"]
                            .map((label) => _categoryChip(label))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: filteredPosts.isEmpty
                          ? const Center(child: Text("해당 카테고리에 글이 없습니다."))
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) => _buildPostItem(filteredPosts[index]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryChip(String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? darkText : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? darkText : const Color(0xFFEEEEEE)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : const Color(0xFF868B94),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(CommunityPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityDetailView(post: post))),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.tag, style: TextStyle(fontSize: 11, color: brandYellow.withOpacity(0.8), fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text("${post.user} · ${post.town}", style: TextStyle(fontSize: 12, color: darkText.withOpacity(0.4))),
                  const Spacer(),
                  const Icon(Icons.thumb_up_rounded, size: 14, color: brandYellow),
                  const SizedBox(width: 4),
                  Text(post.likes.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
    return Column(
      children: [
        _buildHeader("나의 활동", "마이 수호"),
        Expanded(
          child: _buildWhiteContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  _buildStatRow(),
                  const SizedBox(height: 30),
                  _buildMenuCard(Icons.history_rounded, "나의 수호 요청 히스토리"),
                  _buildMenuCard(Icons.edit_note_rounded, "내가 쓴 동네생활 글"),
                  _buildMenuCard(Icons.favorite_rounded, "관심 있는 절약 정보"),
                  const Divider(height: 40, color: softGray, thickness: 2),
                  _buildMenuCard(Icons.notifications_none_rounded, "공지사항"),
                  _buildMenuCard(Icons.help_outline_rounded, "자주 묻는 질문"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: brandYellow,
          child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("지갑 수호대장", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkText)),
            Text("삼성동 #12345", style: TextStyle(color: Color(0xFFADB5BD), fontSize: 14)),
          ],
        ),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: Color(0xFFADB5BD))),
      ],
    );
  }

  Widget _buildStatRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: softGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("기각시킨 지름", "12건", accentRed),
          _statItem("수호한 금액", "34만원", Colors.green),
          _statItem("수호 온도", "37.5℃", brandYellow),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: darkText.withOpacity(0.4), fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildMenuCard(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: softGray, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: darkText, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFADB5BD)),
      onTap: () {},
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
      backgroundColor: brandYellow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // AppBar leading 아이콘 여백 확보
        leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: darkText, size: 28),
            onPressed: () => Navigator.pop(context)
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8), // 상단 여백 추가
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  Provider.of<CommunityProvider>(context, listen: false).addPost(selectedTag, _titleController.text, _contentController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: darkText,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              ),
              child: const Text("완료", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildHeader("소중한 의견", "생활 글쓰기"),
          Expanded(
            child: _buildWhiteContainer(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildInputCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("카테고리", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFADB5BD))),
                          DropdownButton<String>(
                            value: selectedTag,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            items: ["절약꿀팁", "동네질문", "가계부공유", "수호성공"].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                            onChanged: (v) => setState(() => selectedTag = v!),
                          ),
                          const Divider(color: softGray),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(hintText: "제목을 입력하세요", border: InputBorder.none),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputCard(
                      child: TextField(
                        controller: _contentController,
                        maxLines: 10,
                        decoration: const InputDecoration(hintText: "동네 분들과 나누고 싶은 이야기를 적어주세요.", border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 공통 디자인 가이드용 헬퍼 위젯 ---

Widget _buildHeader(String sub, String main) {
  return Container(
    width: double.infinity,
    // 상단 Padding을 10에서 24로 늘려 탑바와 텍스트 사이 여백 확보
    padding: const EdgeInsets.fromLTRB(28, 24, 28, 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sub, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText.withOpacity(0.6))),
        const SizedBox(height: 4),
        Text(main, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: darkText, letterSpacing: -1.0)),
      ],
    ),
  );
}

Widget _buildWhiteContainer({required Widget child}) {
  return Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: softGray,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(44), topRight: Radius.circular(44)),
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(44), topRight: Radius.circular(44)),
      child: child,
    ),
  );
}

Widget _buildInputCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
    ),
    child: child,
  );
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
          backgroundColor: brandYellow,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: darkText),
            // AppBar 높이 조절이나 Leading 아이콘 정렬을 위한 설정 가능
          ),
          body: Column(
            children: [
              _buildHeader(currentPost.tag, "동네생활 상세"),
              Expanded(
                child: _buildWhiteContainer(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentPost.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkText)),
                        const SizedBox(height: 8),
                        Text("${currentPost.user} · ${currentPost.town} · ${currentPost.time}", style: TextStyle(color: darkText.withOpacity(0.4), fontSize: 13)),
                        const Divider(height: 40, color: Color(0xFFEEEEEE)),
                        Text(currentPost.content, style: const TextStyle(fontSize: 16, height: 1.7, color: darkText)),
                        const SizedBox(height: 40),
                        Center(
                          child: InkWell(
                            onTap: () => provider.likePost(currentPost.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(color: brandYellow, borderRadius: BorderRadius.circular(30)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.thumb_up_rounded, size: 18, color: darkText),
                                  const SizedBox(width: 8),
                                  Text("도움이 됐어요 ${currentPost.likes}", style: const TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}