import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buds/providers/my_page_provider.dart';
import 'package:buds/config/theme.dart';

/// 기상 시간 섹션 위젯
class WakeUpSection extends StatelessWidget {
  const WakeUpSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myPageProvider = Provider.of<MyPageProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            '기상시간 알림',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showTimePickerBottomSheet(context, myPageProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_sunny, color: AppColors.primary, size: 40),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오전 ${myPageProvider.wakeUpTime.hour}시 ${myPageProvider.wakeUpTime.minute}분',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '일어날 예정',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTimePickerBottomSheet(
    BuildContext context,
    MyPageProvider provider,
  ) {
    final currentTime = provider.wakeUpTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Text(
                      '기상 시간 설정',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: TimePickerSpinner(
                      time: provider.wakeUpTime,
                      onTimeChange: (time) {
                        setState(() {
                          provider.wakeUpTime = time;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// 시간 선택 스피너 위젯
class TimePickerSpinner extends StatelessWidget {
  final TimeOfDay time;
  final Function(TimeOfDay) onTimeChange;

  const TimePickerSpinner({
    Key? key,
    required this.time,
    required this.onTimeChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 시간 선택 스피너 (오전 4시~12시로 제한)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Text(
                  '시',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildSpinner(
                    context,
                    List.generate(9, (index) => index + 4), // 4~12시
                    time.hour < 4 || time.hour > 12
                        ? 7
                        : time.hour, // 범위 밖이면 기본값 7시로
                    (value) => onTimeChange(
                      TimeOfDay(hour: value, minute: time.minute),
                    ),
                    '',
                  ),
                ),
              ],
            ),
          ),

          // 구분선
          Container(
            height: 150,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),

          // 분 선택 스피너
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Text(
                  '분',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildSpinner(
                    context,
                    List.generate(12, (index) => index * 5),
                    time.minute,
                    (value) =>
                        onTimeChange(TimeOfDay(hour: time.hour, minute: value)),
                    '',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinner(
    BuildContext context,
    List<int> values,
    int selectedValue,
    Function(int) onChanged,
    String suffix,
  ) {
    return ListWheelScrollView.useDelegate(
      itemExtent: 50,
      perspective: 0.005,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final value = values[index % values.length];
          final isSelected = value == selectedValue;

          return Container(
            alignment: Alignment.center,
            child: Text(
              '$value$suffix',
              style: TextStyle(
                fontSize: isSelected ? 26 : 20,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black54,
              ),
            ),
          );
        },
        childCount: 1000, // 무한 스크롤 효과를 위해
      ),
      controller: FixedExtentScrollController(
        initialItem: values.indexOf(selectedValue) + 500,
      ),
      onSelectedItemChanged: (index) {
        final value = values[index % values.length];
        onChanged(value);
      },
    );
  }
}
