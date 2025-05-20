import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:buds/services/api_service.dart';

class AdminQuestionDetailScreen extends StatefulWidget {
  final int userId;
  const AdminQuestionDetailScreen({super.key, required this.userId});

  @override
  State<AdminQuestionDetailScreen> createState() => _AdminQuestionDetailScreenState();
}

class _AdminQuestionDetailScreenState extends State<AdminQuestionDetailScreen> {
  Map<String, dynamic>? questionData;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchQuestionDetail();
  }

  Future<void> fetchQuestionDetail() async {
    setState(() { isLoading = true; errorMsg = null; });
    try {
      final apiService = DioApiService(); // 싱글톤 인스턴스 사용
      
      // API 호출 (상대 경로 사용)
      final res = await apiService.get('/admin/cs/users/${widget.userId}');
      
      setState(() {
        questionData = res.data;
        isLoading = false;
      });
      
      debugPrint('문의 상세 조회 성공!');
    } catch (e) {
      setState(() {
        errorMsg = '문의 상세 조회 실패: $e';
        isLoading = false;
      });
      debugPrint('문의 상세 조회 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 상세'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.brown[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
              ? Center(child: Text(errorMsg!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      ...((questionData?["resMsg"]?["questions"] ?? []) as List).map((q) => Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 사용자 정보
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.brown[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.brown[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${q["user"]["userName"]} (${q["user"]["userEmail"]})', 
                                            style: const TextStyle(fontWeight: FontWeight.bold)
                                          ),
                                          if (q["user"]["tagTypes"] != null)
                                            Wrap(
                                              spacing: 4,
                                              children: (q["user"]["tagTypes"] as List).map((tag) => 
                                                Chip(
                                                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                                                  backgroundColor: AppColors.primary.withOpacity(0.2),
                                                  padding: EdgeInsets.zero,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                )
                                              ).toList(),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // 문의 내용
                              Text('제목: ${q["subject"] ?? "-"}', 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 18
                                )
                              ),
                              const SizedBox(height: 8),
                              Text('내용: ${q["content"] ?? "-"}'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: q["status"] == "ANSWERED" 
                                      ? Colors.green[100] 
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                child: Text(
                                  '상태: ${q["status"] == "ANSWERED" ? "답변완료" : "미답변"}',
                                  style: TextStyle(
                                    color: q["status"] == "ANSWERED" 
                                        ? Colors.green[800] 
                                        : Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // 답변 영역
                              if (q["answer"] != null) ...[
                                const Divider(thickness: 1),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.comment, color: Colors.blue[600]),
                                          const SizedBox(width: 8),
                                          const Text('답변', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('${q["answer"]["content"] ?? "-"}'),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${q["answer"]["createdAt"] ?? "-"}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // 날짜 정보
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '문의일: ${q["createdAt"] ?? "-"}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
    );
  }
} 