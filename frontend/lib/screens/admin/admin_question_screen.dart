// Flutter imports:
import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:buds/services/api_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'admin_question_detail_screen.dart';

/// 문의 관리 화면
class AdminQuestionScreen extends StatefulWidget {
  const AdminQuestionScreen({super.key});

  @override
  State<AdminQuestionScreen> createState() => _AdminQuestionScreenState();
}

class _AdminQuestionScreenState extends State<AdminQuestionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> answeredList = [];
  List<dynamic> unansweredList = [];
  bool isLoading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchQuestions();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      fetchQuestions();
    });
  }

  Future<void> fetchQuestions() async {
    setState(() { isLoading = true; errorMsg = null; });
    try {
      final apiService = DioApiService(); // 싱글톤 인스턴스 사용
      final apiUrl = dotenv.env['API_URL'] ?? '';
      
      // 답변된 문의
      final answeredRes = await apiService.get('/admin/cs/answered-questions');
      // 미답변 문의
      final unansweredRes = await apiService.get('/admin/cs/unanswered-questions');
      
      setState(() {
        answeredList = answeredRes.data['resMsg'] ?? [];
        unansweredList = unansweredRes.data['resMsg'] ?? [];
        isLoading = false;
      });
      
      debugPrint('문의 목록 조회 성공!');
    } catch (e) {
      setState(() {
        errorMsg = '문의 목록 조회 실패: $e';
        isLoading = false;
      });
      debugPrint('문의 목록 조회 실패: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: '문의 내역 관리',
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 탭바
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: '답변된 문의'),
                Tab(text: '미답변 문의'),
              ],
            ),
          ),
          // 탭 뷰
          Expanded(
            child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMsg != null
                  ? Center(child: Text(errorMsg!))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildQuestionList(answeredList),
                        _buildQuestionList(unansweredList),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList(List<dynamic> list) {
    if (list.isEmpty) {
      return const Center(child: Text('문의가 없습니다.'));
    }
    
    // 목록을 최신순으로 정렬
    final sortedList = List.from(list);
    sortedList.sort((a, b) {
      DateTime dateA = DateTime.parse(a['lastQuestionedAt']);
      DateTime dateB = DateTime.parse(b['lastQuestionedAt']);
      return dateB.compareTo(dateA); // 내림차순 정렬 (최신순)
    });
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sortedList.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, idx) {
        final item = sortedList[idx];
        return Card(
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text('유저Id: ${item['userId']}', 
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('최근 문의일: ${item['lastQuestionedAt']}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminQuestionDetailScreen(userId: item['userId']),
                ),
              ).then((_) => fetchQuestions()); // 상세화면 복귀 시 목록 갱신
            },
          ),
        );
      },
    );
  }
} 