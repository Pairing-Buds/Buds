// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/services/activity_service.dart';

class BookRecommendation extends StatefulWidget {
  const BookRecommendation({super.key});

  @override
  State<BookRecommendation> createState() => _BookRecommendationState();
}

class _BookRecommendationState extends State<BookRecommendation> {
  final ActivityService _activityService = ActivityService();

  String? title;
  String? author;
  String? cover;

  @override
  void initState() {
    super.initState();
    loadBook();
  }

  Future<void> loadBook() async {
    try {
      final data = await _activityService.fetchMentalHealthBook();
      setState(() {
        title = _trimTitle(data['title'] ?? '');
        author = _trimAuthor(data['author'] ?? '');
        cover = data['cover'];
      });
    } catch (e) {
      debugPrint('책 추천 에러: $e');
    }
  }

  String _trimTitle(String fullTitle) {
    final separators = [':', ' - ', ' – '];
    for (final sep in separators) {
      if (fullTitle.contains(sep)) {
        return fullTitle.split(sep)[0].trim();
      }
    }
    return fullTitle.trim();
  }

  String _trimAuthor(String fullAuthor) {
    final separators = [',', '·', '/', '&'];
    for (final sep in separators) {
      if (fullAuthor.contains(sep)) {
        return fullAuthor.split(sep)[0].trim();
      }
    }
    return fullAuthor.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (title == null || author == null || cover == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final cardHeight = screenHeight * 0.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '버즈의 책 추천',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              cover != null
                  ? Image.network(
                cover!,
                width: 100,
                height: 120,
                fit: BoxFit.cover,
              )
                  : const SizedBox(width: 60, height: 90),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '제목 없음',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '저자: ${author ?? '저자 없음'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
