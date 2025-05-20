import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/widgets/common_dialog.dart';
import 'package:buds/providers/admin_cs_provider.dart';
import 'package:buds/models/admin_question_model.dart';
import 'package:provider/provider.dart';
import 'package:buds/widgets/toast_bar.dart';

class AdminQuestionDetailScreen extends StatefulWidget {
  final int userId;
  const AdminQuestionDetailScreen({super.key, required this.userId});

  @override
  State<AdminQuestionDetailScreen> createState() => _AdminQuestionDetailScreenState();
}

class _AdminQuestionDetailScreenState extends State<AdminQuestionDetailScreen> {
  // 답변 작성 컨트롤러
  final TextEditingController _answerController = TextEditingController();
  // 답변 수정 컨트롤러
  final TextEditingController _editAnswerController = TextEditingController();
  
  late AdminCSProvider _provider;

  @override
  void initState() {
    super.initState();
    // Provider 초기화
    _provider = Provider.of<AdminCSProvider>(context, listen: false);
    // 빌드 후 데이터 로드 (빌드 중 setState 호출 오류 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    await _provider.fetchUserQuestions(widget.userId);
  }
  
  @override
  void dispose() {
    _answerController.dispose();
    _editAnswerController.dispose();
    super.dispose();
  }

  // 답변 작성 함수
  Future<void> submitAnswer(int questionId) async {
    if (_answerController.text.trim().isEmpty) {
      Toast(context, '답변 내용을 입력하세요.', icon: const Icon(Icons.warning, color: Colors.white, size: 20));
      return;
    }
    
    final success = await _provider.submitAnswer(
      widget.userId, 
      questionId, 
      _answerController.text.trim()
    );
    
    if (success) {
      _answerController.clear();
      Toast(context, '답변이 등록되었습니다.', icon: const Icon(Icons.check_circle, color: Colors.white, size: 20));
    } else {
      Toast(
        context, 
        _provider.error ?? '답변 등록에 실패했습니다.', 
        icon: const Icon(Icons.error, color: Colors.white, size: 20)
      );
      _provider.clearError();
    }
  }
  
  // 답변 수정 함수
  Future<void> editAnswer(int? answerId, String currentAnswer) async {
    // answerId가 null이거나 숫자가 아닌 경우
    if (answerId == null) {
      Toast(context, '답변 ID가 존재하지 않습니다.', icon: const Icon(Icons.error, color: Colors.white, size: 20));
      return;
    }
    
    _editAnswerController.text = currentAnswer;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('답변 수정'),
        content: TextField(
          controller: _editAnswerController,
          decoration: const InputDecoration(hintText: '수정할 답변 내용을 입력하세요'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              if (_editAnswerController.text.trim().isEmpty) {
                Navigator.pop(context);
                return;
              }
              
              Navigator.pop(context);
              
              final success = await _provider.updateAnswer(
                widget.userId,
                answerId,
                _editAnswerController.text.trim()
              );
              
              if (success) {
                Toast(context, '답변이 수정되었습니다.', icon: const Icon(Icons.check_circle, color: Colors.white, size: 20));
              } else {
                Toast(
                  context, 
                  _provider.error ?? '답변 수정에 실패했습니다.', 
                  icon: const Icon(Icons.error, color: Colors.white, size: 20)
                );
                _provider.clearError();
              }
            },
            child: const Text('수정', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
  
  // 답변 삭제 함수
  Future<void> deleteAnswer(int? answerId) async {
    // answerId가 null이거나 숫자가 아닌 경우
    if (answerId == null) {
      Toast(context, '답변 ID가 존재하지 않습니다.', icon: const Icon(Icons.error, color: Colors.white, size: 20));
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => CommonDialog(
        title: '답변 삭제',
        description: '정말로 이 답변을 삭제하시겠습니까?',
        cancelText: '취소',
        confirmText: '삭제',
        confirmColor: Colors.red[100]!,
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          Navigator.pop(context);
          
          final success = await _provider.deleteAnswer(widget.userId, answerId);
          
          if (success) {
            Toast(context, '답변이 삭제되었습니다.', icon: const Icon(Icons.check_circle, color: Colors.white, size: 20));
          } else {
            Toast(
              context, 
              _provider.error ?? '답변 삭제에 실패했습니다.', 
              icon: const Icon(Icons.error, color: Colors.white, size: 20)
            );
            _provider.clearError();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: '문의 상세',
        centerTitle: true,
        showBackButton: true,
      ),
      body: Consumer<AdminCSProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          
          final questions = provider.questions;
          
          if (questions.isEmpty) {
            return const Center(child: Text('문의 내역이 없습니다.'));
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ...questions.map((q) => _buildQuestionCard(q)),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildQuestionCard(Question q) {
    return Card(
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
                          '${q.user.userName} (${q.user.userEmail})', 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        if (q.user.tagTypes != null && q.user.tagTypes!.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: q.user.tagTypes!.map((tag) => 
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
            Text('제목: ${q.subject}', 
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 18
              )
            ),
            const SizedBox(height: 8),
            Text('내용: ${q.content}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: q.status == "ANSWERED" 
                    ? Colors.green[100] 
                    : Colors.orange[100],
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text(
                '상태: ${q.status == "ANSWERED" ? "답변완료" : "미답변"}',
                style: TextStyle(
                  color: q.status == "ANSWERED" 
                      ? Colors.green[800] 
                      : Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 답변 영역
            if (q.answer != null) ...[
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.comment, color: Colors.blue[600]),
                            const SizedBox(width: 8),
                            const Text('답변', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue[600], size: 16),
                              onPressed: () => editAnswer(q.answer?.answerId, q.answer?.content ?? ""),
                              splashRadius: 20,
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[300], size: 16),
                              onPressed: () => deleteAnswer(q.answer?.answerId),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(q.answer?.content ?? "-"),
                    const SizedBox(height: 4),
                    Text(
                      q.answer?.createdAt ?? "-",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 미답변 상태일 때 답변 작성 폼 표시
              const Divider(thickness: 1),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.question_answer, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('답변 작성', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        hintText: '답변 내용을 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => submitAnswer(q.questionId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('답변 등록'),
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
                '문의일: ${q.createdAt}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 