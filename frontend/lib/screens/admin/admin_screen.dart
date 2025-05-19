// Flutter imports:
import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:buds/services/api_service.dart';
import 'admin_question_detail_screen.dart';

/// 관리자 화면
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
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
      appBar: AppBar(
        title: const Text('관리자 페이지'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.brown[800],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '답변된 문의'),
            Tab(text: '미답변 문의'),
          ],
        ),
      ),
      body: isLoading
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
    );
  }

  Widget _buildQuestionList(List<dynamic> list) {
    if (list.isEmpty) {
      return const Center(child: Text('문의가 없습니다.'));
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, idx) {
        final item = list[idx];
        return ListTile(
          title: Text('userId: ${item['userId']}'),
          subtitle: Text('최근 문의일: ${item['lastQuestionedAt']}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminQuestionDetailScreen(userId: item['userId']),
              ),
            );
          },
        );
      },
    );
  }
} 