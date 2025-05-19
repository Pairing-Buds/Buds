// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';

/// 관리자 화면
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('관리자 페이지'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.brown[800],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '관리자 대시보드',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 20),
              // 여기에 관리자 기능들을 추가할 수 있습니다
              Card(
                child: ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('사용자 관리'),
                  onTap: () {
                    // 사용자 관리 기능 구현
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('시스템 설정'),
                  onTap: () {
                    // 시스템 설정 기능 구현
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 