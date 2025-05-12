// Flutter imports:
import 'package:flutter/material.dart';

class StepActionButtons extends StatelessWidget {
  const StepActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.menu_book,
                size: 32,
                color: Colors.green,
              ),
              title: const Text('도서관 목록 보기'),
              onTap: () {
                // 도서관 목록 페이지로 이동
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.park, size: 32, color: Colors.green),
              title: const Text('공원 목록 보기'),
              onTap: () {
                // 공원 목록 페이지로 이동
              },
            ),
          ),
        ],
      ),
    );
  }
}
