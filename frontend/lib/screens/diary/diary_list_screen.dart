import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/diary_model.dart';
import '../../services/diary_service.dart';
import 'package:buds/screens/diary/widgets/diary_card.dart';
import 'package:buds/screens/diary/widgets/EditDiaryBottomSheet.dart';
import 'package:buds/widgets/common_dialog.dart';
import 'package:buds/widgets/toast_bar.dart';

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

  void _scrollToSelectedDate() {
    final key = _itemKeys[widget.selectedDate.toIso8601String().substring(0, 10)];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        alignment: 0.2,
      );
    } else {
      print('❌ 스크롤할 키 없음: ${widget.selectedDate.toIso8601String().substring(0, 10)}');
      print('✅ 등록된 키들: ${_itemKeys.keys}');
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

        final diaryDays = snapshot.data!;
        final visibleDays = diaryDays
            .where((day) => day.diaryList.isNotEmpty)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // 최신순 정렬

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 6),
                Expanded(
                  child: visibleDays.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/marmet_head.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '작성된 일기가 없어요',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        itemCount: visibleDays.length,
                        itemBuilder: (context, index) {
                          final day = visibleDays[index];
                          final key = GlobalKey();
                          final dateKey = DateTime.parse(day.date).toIso8601String().substring(0, 10);
                          _itemKeys[dateKey] = key;

                          return Container(
                            key: key,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: DiaryCard(
                              date: DateTime.parse(day.date),
                              badgeIcons: day.badgeList
                                  .map((b) => 'assets/icons/badges/$b.png')
                                  .toList(),
                              emotionContent: day.diaryList
                                  .where((e) => e.diaryType == 'EMOTION')
                                  .map((e) => e.content)
                                  .join('\n'),
                              activityContent: day.diaryList
                                  .where((e) => e.diaryType == 'ACTIVE')
                                  .map((e) => e.content)
                                  .join('\n'),
                              showEditButton: true, // ✅ 이걸 true로
                              showRecordButton: false,
                              hasShadow: true,
                              onEditPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                  ),
                                  builder: (_) {
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.edit),
                                            title: const Text('수정하기'),
                                            onTap: () {
                                              Navigator.pop(context); // 액션시트 닫기
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                                ),
                                                builder: (_) => EditDiaryBottomSheet(
                                                  diaryDay: day,
                                                  onUpdated: () {
                                                    setState(() {
                                                      _diaryDaysFuture = DiaryService().getDiaryByMonth(_formatDate(widget.selectedDate));
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete),
                                            title: const Text('삭제하기'),
                                            onTap: () async {
                                              Navigator.pop(context); // 액션시트 닫기

                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (_) => CommonDialog(
                                                  title: '삭제하시겠어요?',
                                                  description: '삭제된 일기는 복구할 수 없어요.',
                                                  cancelText: '취소',
                                                  confirmText: '삭제',
                                                  confirmColor: Colors.redAccent,
                                                  onCancel: () => Navigator.pop(context, false),
                                                  onConfirm: () => Navigator.pop(context, true),
                                                ),
                                              );

                                              if (confirm == true) {
                                                final success = await DiaryService().deleteDiary(day.diaryList.first.diaryNo);
                                                if (success) {
                                                  Toast(context, '일기가 삭제되었어요.');
                                                  setState(() {
                                                    _diaryDaysFuture = DiaryService().getDiaryByMonth(_formatDate(widget.selectedDate));
                                                  });
                                                } else {
                                                  Toast(context, '삭제에 실패했어요.');
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                      Builder(
                        builder: (_) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Future.delayed(Duration.zero, () {
                              if (mounted) _scrollToSelectedDate();
                            });
                          });
                          return const SizedBox.shrink();
                        },
                      )
                    ],
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
