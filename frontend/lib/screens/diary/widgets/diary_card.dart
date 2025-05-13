// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../config/theme.dart';

class DiaryCard extends StatelessWidget {
  final DateTime date;
  final List<String> badgeIcons;
  final bool showEditButton;
  final bool showRecordButton;
  final bool hasShadow;
  final VoidCallback? onEditPressed;
  final VoidCallback? onRecordPressed;

  // 값 기반 표시용
  final String? emotionContent;
  final String? activityContent;

  // 입력 기반 (작성/수정용)
  final ValueChanged<String>? onEmotionChanged;
  final ValueChanged<String>? onActivityChanged;
  final TextEditingController? emotionController;
  final TextEditingController? activityController;

  const DiaryCard({
    Key? key,
    required this.date,
    required this.badgeIcons,
    this.showEditButton = false,
    this.showRecordButton = false,
    this.hasShadow = false,
    this.onEditPressed,
    this.onRecordPressed,
    this.emotionContent,
    this.activityContent,
    this.onEmotionChanged,
    this.onActivityChanged,
    this.emotionController,
    this.activityController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: hasShadow
            ? [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showEditButton)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 24, color: Colors.grey),
                  onPressed: onEditPressed,
                ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: badgeIcons
                .map((path) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Image.asset(path, width: 55, height: 55),
            ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${date.year}. ${_twoDigits(date.month)}. ${_twoDigits(date.day)} ${_weekdayKor(date.weekday)}',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ),

          const SizedBox(height: 40),
          _buildLabel('감정일기'),
          const SizedBox(height: 12),
          _buildEmotionField(),

          const SizedBox(height: 24),
          _DashedLine(),
          const SizedBox(height: 24),

          _buildLabel('활동일기'),
          const SizedBox(height: 12),
          _buildActivityField(),

          if (showRecordButton) ...[
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: onRecordPressed,
                  child: const Text('수정하기'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionField() {
    if (emotionController != null) {
      return TextField(
        controller: emotionController,
        maxLines: 4,
        decoration: _inputDecoration('오늘의 감정을 입력해주세요'),
      );
    } else if (onEmotionChanged != null) {
      return TextField(
        onChanged: onEmotionChanged,
        maxLines: 4,
        decoration: _inputDecoration('오늘의 감정을 입력해주세요'),
      );
    } else if (emotionContent?.isNotEmpty == true) {
      return Text(
        emotionContent!,
        style: const TextStyle(fontSize: 14, height: 1.6),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildActivityField() {
    if (activityController != null) {
      return TextField(
        controller: activityController,
        maxLines: 4,
        decoration: _inputDecoration('오늘의 활동을 입력해주세요'),
      );
    } else if (onActivityChanged != null) {
      return TextField(
        onChanged: onActivityChanged,
        maxLines: 4,
        decoration: _inputDecoration('오늘의 활동을 입력해주세요'),
      );
    } else if (activityContent?.isNotEmpty == true) {
      return Text(
        activityContent!,
        style: const TextStyle(fontSize: 14, height: 1.6),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  static Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static String _weekdayKor(int weekday) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}

// 점선 구분선
class _DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey),
              ),
            );
          }),
        );
      },
    );
  }
}
