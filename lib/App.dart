// App.dart
import 'package:flutter/material.dart';
import 'package:midterm_project/provider/service_provider.dart';
import 'package:midterm_project/main.dart';
import 'package:provider/provider.dart';
import 'package:midterm_project/models/community_post.dart';
import 'package:midterm_project/provider/community_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:midterm_project/models/guard_article.dart';

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
            BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: '심판대'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: '수다방'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '소비 기록'),
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
        _buildHeader("텅장 방어", "오늘의 심판대"),
        Expanded(
          child: _buildWhiteContainer(
            child: Consumer<ServiceProvider>(
              builder: (context, service, child) {
                if (service.articles.isEmpty) {
                  return const Center(child: Text("등록된 심판 목록이 없습니다."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: service.articles.length,
                  itemBuilder: (context, index) {
                    final item = service.articles[index];
                    // _buildServiceCard에 context를 추가로 넘겨줍니다.
                    return _buildServiceCard(item, service, context);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(item, service, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GuardArticleDetailView(article: item),
          ),
        );
      },
      child: Container(
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
            const SizedBox(height: 8),
            Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: darkText)),
            const SizedBox(height: 4),
            Text("₩${item.price}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: accentRed)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildVoteBtn(Icons.close_rounded, "참아라", item.rejectCnt, Colors.grey, () => service.vote(item.id, false))),
                const SizedBox(width: 10),
                Expanded(child: _buildVoteBtn(Icons.check_rounded, "사라", item.approveCnt, brandYellow, () => service.vote(item.id, true))),
              ],
            ),
          ],
        ),
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
        _buildHeader("거지들의 수다", "정보 공유"),
        Expanded(
          child: _buildWhiteContainer(
            child: Consumer<CommunityProvider>(
              builder: (context, provider, child) {
                final filteredPosts = selectedCategory == "전체"
                    ? provider.posts
                    : provider.posts.where((post) => post.tag == selectedCategory).toList();

                return Column(
                  children: [
                    // 👈 SingleChildScrollView + Row 대신 Wrap 사용
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Wrap(
                        spacing: 8, // 칩 사이 가로 간격
                        runSpacing: 8, // 줄바꿈 시 세로 간격
                        children: ["전체", "절약꿀팁", "동네질문", "가계부공유", "방어성공"]
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
        _buildHeader("나의 지출", "소비 기록"),
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
                  _buildMenuCard(Icons.history_rounded, "심판 내역", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyListScreen(type: 'article')));
                  }),
                  _buildMenuCard(Icons.edit_note_rounded, "내가 쓴 글", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyListScreen(type: 'post')));
                  }),
                  _buildMenuCard(Icons.favorite_rounded, "관심 있는 절약 정보", () {}),
                  const Divider(height: 40, color: softGray, thickness: 2),
                  _buildMenuCard(Icons.notifications_none_rounded, "공지사항", () {}),
                  _buildMenuCard(Icons.help_outline_rounded, "자주 묻는 질문", () {}),
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
          _statItem("참아낸 지출", "12건", accentRed),
          _statItem("텅장 방어액", "34만원", Colors.green),
          _statItem("절약 온도", "37.5℃", brandYellow),
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

  Widget _buildMenuCard(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: softGray, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: darkText, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFADB5BD)),
      onTap: onTap, // 👈 추가된 onTap 연결
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
          _buildHeader("거지들의 수다", "글쓰기"),
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
                            items: ["절약꿀팁", "동네질문", "가계부공유", "방어성공"].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                            onChanged: (v) => setState(() => selectedTag = v!),
                          ),
                          const Divider(color: softGray),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: "제목을 입력하세요",
                              hintStyle: TextStyle(color: darkText.withOpacity(0.3)),
                              border: InputBorder.none,
                            ),
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
                        decoration: InputDecoration(
                          hintText: "어떻게 방어했는지, 혹은 무엇이 궁금한지 적어주세요.",
                          hintStyle: TextStyle(color: darkText.withOpacity(0.3)),
                          border: InputBorder.none,
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

class CommunityDetailView extends StatefulWidget {
  final CommunityPost post;
  const CommunityDetailView({super.key, required this.post});

  @override
  State<CommunityDetailView> createState() => _CommunityDetailViewState();
}

class _CommunityDetailViewState extends State<CommunityDetailView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        // 현재 화면에 띄울 게시글의 최신 상태(추천수)를 가져옵니다.
        final currentPost = provider.posts.firstWhere(
              (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        );

        return Scaffold(
          backgroundColor: brandYellow,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: darkText),
          ),
          body: Column(
            children: [
              _buildHeader(currentPost.tag, "동네생활 상세"),
              Expanded(
                child: _buildWhiteContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. 본문 및 공감 버튼 영역
                      Container(
                        color: Colors.white,
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

                            // 공감(추천) 버튼
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

                      // 2. 게시글과 댓글을 나누는 굵은 구분선
                      const Divider(color: softGray, thickness: 8, height: 8),

                      // 3. 실시간 댓글 영역 (StreamBuilder)
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: provider.getCommentsStream(widget.post.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: brandYellow));
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text("가장 먼저 댓글을 남겨보세요!", style: TextStyle(color: darkText.withOpacity(0.5))),
                              );
                            }

                            final comments = snapshot.data!.docs;
                            return ListView.separated(
                              padding: const EdgeInsets.all(24),
                              itemCount: comments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                var data = comments[index].data() as Map<String, dynamic>;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: brandYellow,
                                      child: Icon(Icons.person_rounded, size: 22, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data['user'] ?? '동네 이웃', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                                          const SizedBox(height: 6),
                                          Text(data['content'] ?? '', style: TextStyle(fontSize: 15, color: darkText.withOpacity(0.8), height: 1.4)),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. 댓글 입력창 (키보드 대응)
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 20, right: 20, top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20, // 키보드 높이만큼 패딩
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "댓글을 입력해주세요...",
                          hintStyle: TextStyle(color: darkText.withOpacity(0.3), fontSize: 14),
                          filled: true,
                          fillColor: softGray,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        if (_commentController.text.isNotEmpty) {
                          provider.addComment(widget.post.id, _commentController.text);
                          _commentController.clear();
                        }
                      },
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: darkText,
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class GuardArticleDetailView extends StatefulWidget {
  final GuardArticle article;
  const GuardArticleDetailView({super.key, required this.article});

  @override
  State<GuardArticleDetailView> createState() => _GuardArticleDetailViewState();
}

class _GuardArticleDetailViewState extends State<GuardArticleDetailView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 상세 페이지 전용 투표 버튼 디자인 (버튼이 더 잘 보이도록 스타일을 살짝 조절했습니다)
  Widget _buildDetailVoteBtn(IconData icon, String label, int count, Color color, VoidCallback onTap) {
    bool isYellow = color == brandYellow;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isYellow ? brandYellow : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isYellow ? null : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: darkText),
            const SizedBox(width: 6),
            Text("$label $count", style: const TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumer를 최상단에 배치하여 투표를 누를 때마다 화면의 숫자가 즉시 바뀌도록 합니다.
    return Consumer<ServiceProvider>(
      builder: (context, service, child) {
        // 현재 화면에 띄울 게시글의 최신 상태(투표수)를 리스트에서 찾아옵니다.
        final currentArticle = service.articles.firstWhere(
              (a) => a.id == widget.article.id,
          orElse: () => widget.article,
        );

        return Scaffold(
          backgroundColor: brandYellow,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: darkText),
            title: const Text("심판대 상세", style: TextStyle(fontWeight: FontWeight.bold, color: darkText, fontSize: 18)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: _buildWhiteContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. 원본 게시글 & 투표 버튼 영역 (배경을 흰색으로 분리)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentArticle.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkText)),
                            const SizedBox(height: 8),
                            Text("₩${currentArticle.price}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accentRed)),
                            const SizedBox(height: 16),
                            Text(currentArticle.content, style: TextStyle(fontSize: 15, color: darkText.withOpacity(0.8), height: 1.6)),
                            const SizedBox(height: 30),

                            // 투표 버튼 추가
                            Row(
                              children: [
                                Expanded(child: _buildDetailVoteBtn(Icons.close_rounded, "참아라", currentArticle.rejectCnt, Colors.grey, () => service.vote(currentArticle.id, false))),
                                const SizedBox(width: 12),
                                Expanded(child: _buildDetailVoteBtn(Icons.check_rounded, "사라", currentArticle.approveCnt, brandYellow, () => service.vote(currentArticle.id, true))),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 2. 게시글과 댓글 영역을 나누는 굵은 구분선
                      const Divider(color: softGray, thickness: 8, height: 8),

                      // 3. 실시간 댓글 영역 (StreamBuilder)
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: service.getCommentsStream(widget.article.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: brandYellow));
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text("가장 먼저 팩폭을 남겨보세요!", style: TextStyle(color: darkText.withOpacity(0.5))),
                              );
                            }

                            final comments = snapshot.data!.docs;
                            return ListView.separated(
                              padding: const EdgeInsets.all(24),
                              itemCount: comments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                var data = comments[index].data() as Map<String, dynamic>;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: brandYellow,
                                      child: Icon(Icons.person_rounded, size: 22, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data['user'] ?? '익명 대원', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                                          const SizedBox(height: 6),
                                          Text(data['content'] ?? '', style: TextStyle(fontSize: 15, color: darkText.withOpacity(0.8), height: 1.4)),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. 댓글 입력창 (키보드 대응)
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 20, right: 20, top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20, // 키보드 높이만큼 패딩 추가
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "따끔한 조언을 남겨주세요.",
                          hintStyle: TextStyle(color: darkText.withOpacity(0.3), fontSize: 14),
                          filled: true,
                          fillColor: softGray,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        if (_commentController.text.isNotEmpty) {
                          service.addComment(widget.article.id, _commentController.text);
                          _commentController.clear();
                        }
                      },
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: darkText,
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2초 대기 후 메인 화면(MainNavigationPage)으로 이동
    Future.delayed(const Duration(seconds: 5), () {
      // pushReplacement를 사용하여 뒤로가기 버튼을 눌러도 다시 스플래시로 돌아오지 않게 합니다.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandYellow, // 앱의 시그니처 컬러
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 수호대장을 상징하는 거대한 방패 아이콘
            const Icon(Icons.shield_rounded, size: 100, color: darkText),
            const SizedBox(height: 20),
            // 앱 타이틀
            const Text(
              "거지방",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: darkText,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 12),
            // 서브 카피
            Text(
              "당신의 텅장을 지켜드립니다",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkText.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyListScreen extends StatelessWidget {
  final String type; // 'article' 또는 'post'
  const MyListScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandYellow,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: Text(type == 'article' ? "내 심판 내역" : "내가 쓴 글")),
      body: _buildWhiteContainer(
        child: StreamBuilder<QuerySnapshot>(
          stream: type == 'article'
              ? Provider.of<ServiceProvider>(context).getMyArticlesStream()
              : Provider.of<CommunityProvider>(context).getMyPostsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Center(child: Text("기록이 없습니다."));

            // ... 이전 생략
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                // Firestore 문서를 Map으로 안전하게 변환
                final data = docs[index].data() as Map<String, dynamic>;

                // 데이터가 존재하지 않을 경우를 대비한 안전한 값 할당
                final title = data.containsKey('title') ? data['title'] : '제목 없음';
                final content = data.containsKey('content') ? data['content'] : '내용 없음';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(content, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}