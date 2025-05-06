import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/diary_model.dart';
import '../../services/diary_service.dart';
import 'package:buds/screens/diary/widgets/diary_card.dart';

class DiaryListScreen extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryListScreen({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};
  late Future<List<DiaryDay>> _diaryDaysFuture;

  @override
  void initState() {
    super.initState();
    _diaryDaysFuture = DiaryService().getDiaryByMonth(_formatDate(widget.selectedDate));
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  void _scrollToSelectedDate(List<DiaryDay> filteredDiaryDays) {
    final key = _itemKeys[widget.selectedDate.toIso8601String().substring(0, 10)];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        alignment: 0.2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiaryDay>>(
      future: _diaryDaysFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final diaryDays = snapshot.data!
            .where((day) => day.diaryList.isNotEmpty)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDate(diaryDays));

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: diaryDays.length,
                    itemBuilder: (context, index) {
                      final day = diaryDays[index];
                      final key = GlobalKey();
                      _itemKeys[day.date] = key;

                      return Container(
                        key: key,
                        margin: const EdgeInsets.only(bottom: 24),
                        child: DiaryCard(
                          date: DateTime.parse(day.date),
                          badgeIcons: day.badgeList.map((b) => 'assets/icons/badges/$b.png').toList(),
                          emotionContent: day.diaryList
                              .where((e) => e.diaryType == 'EMOTION')
                              .map((e) => e.content)
                              .join('\n'),
                          activityContent: day.diaryList
                              .where((e) => e.diaryType == 'ACTIVE')
                              .map((e) => e.content)
                              .join('\n'),
                          showEditButton: false,
                          showRecordButton: false,
                          hasShadow: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Center(
            child: Text(
              '${widget.selectedDate.year}년 ${widget.selectedDate.month}월',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
