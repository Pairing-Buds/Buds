import 'package:flutter/material.dart';
import '../../models/diary_model.dart';

// 일기 목록 화면

class DiaryListScreen extends StatelessWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (실제로는 상태 관리 또는 API에서 가져옴)
    final dummyDiaries = [
      Diary(
        id: 1,
        title: '첫 번째 일기',
        content: '오늘은 좋은 날이었다.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Diary(
        id: 2,
        title: '두 번째 일기',
        content: '내일은 더 좋은 날이 될 것이다.',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 목록'),
      ),
      body: ListView.builder(
        itemCount: dummyDiaries.length,
        itemBuilder: (context, index) {
          final diary = dummyDiaries[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(diary.title),
              subtitle: Text(
                diary.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '${diary.date.year}-${diary.date.month}-${diary.date.day}',
              ),
              onTap: () {
                // TODO: 일기 상세 화면으로 이동
                // Navigator.pushNamed(context, '/diary/${diary.id}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 새 일기 작성 화면으로 이동
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
