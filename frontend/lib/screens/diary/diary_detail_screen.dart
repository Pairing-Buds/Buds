import 'package:flutter/material.dart';
import '../../models/diary_model.dart';

// 일기 상세 화면

class DiaryDetailScreen extends StatelessWidget {
  final String id;

  const DiaryDetailScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    // 실제로는 ID로 일기를 조회하는 로직이 필요함
    // 여기서는 임시 데이터를 사용
    final diary = Diary(
      id: int.parse(id),
      title: '일기 제목',
      content: '여기에 일기 내용이 들어갑니다. 이 화면은 ID가 $id인 일기의 상세 내용을 보여줍니다.',
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 수정 화면으로 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // TODO: 삭제 확인 다이얼로그 표시
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diary.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${diary.date.year}년 ${diary.date.month}월 ${diary.date.day}일',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              diary.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
