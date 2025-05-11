import 'package:buds/config/theme.dart';
import 'package:flutter/material.dart';
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
        const Text(
          '이번 달 책 추천입니다',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Container(
          height: cardHeight,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            // color: const Color(0xFFF9F9F9),
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1 / 2, // 책 비율 유지 (보통 2:3)
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    cover!,
                    fit: BoxFit.contain, // 비율 깨지지 않게
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title!,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
