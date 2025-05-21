// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/main.dart';
import 'package:buds/providers/my_page_provider.dart';
import 'package:buds/services/notification_service.dart';
import 'package:buds/widgets/toast_bar.dart';

import 'dart:async'; // Timer 사용을 위한 import 추가
import 'package:buds/services/wake_up_service.dart'; // 추가

// main.dart에서 정의한 전역 알림 서비스 인스턴스를 가져오기 위한 import

/// 기상 시간 섹션 위젯
class WakeUpSection extends StatefulWidget {
  const WakeUpSection({super.key});

  // 시간 선택 바텀시트를 표시하는 static 메서드 추가
  static void showTimePickerBottomSheet(BuildContext context) {
    final myPageProvider = Provider.of<MyPageProvider>(context, listen: false);
    TimeOfDay selectedTime = myPageProvider.wakeUpTime; // 현재 저장된 시간 가져오기

    // 바텀시트 다이얼로그로 대체
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // 바텀시트 닫힘 방지 (사용자가 명시적으로 닫지 않는 한 유지)
      isDismissible: false,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24), // 원래 패딩으로 복원
              height: MediaQuery.of(context).size.height * 0.4, // 원래 높이로 복원
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/sun.png',
                        width: 30, // 원래 크기로 복원
                        height: 30,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '기상 시간 설정',
                        style: TextStyle(
                          fontSize: 22, // 원래 크기로 복원
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // 원래 간격으로 복원
                  Expanded(
                    child: TimePickerSpinner(
                      time: selectedTime,
                      onTimeChange: (time) {
                        setState(() {
                          selectedTime = time;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16), // 원래 간격으로 복원
                  SizedBox(
                    width: double.infinity,
                    height: 56, // 원래 높이로 복원
                    child: ElevatedButton(
                      onPressed: () async {
                        // 선택한 시간을 프로바이더에 저장
                        myPageProvider.wakeUpTime = selectedTime;

                        // 알람 설정 시작 메시지
                        Toast(bottomSheetContext, '알람 설정 중...');

                        // 바텀시트를 화면에 유지한 상태에서 알람 설정 진행 (컨텍스트 문제 방지)
                        try {
                          // 권한 확인
                          final permissions =
                              await NotificationService()
                                  .checkAndRequestAllPermissions();

                          // 권한 관련 토스트
                          if (!permissions['notification']! &&
                              bottomSheetContext.mounted) {
                            Toast(
                              bottomSheetContext,
                              '알림 권한이 필요합니다. 설정에서 알림 권한을 허용해주세요.',
                              icon: const Icon(
                                Icons.warning,
                                color: Colors.orange,
                              ),
                            );
                            // 실패 시 바텀시트 닫기
                            Navigator.pop(bottomSheetContext);
                            return;
                          }

                          if (!permissions['exactAlarm']! &&
                              bottomSheetContext.mounted) {
                            Toast(
                              bottomSheetContext,
                              '정확한 알람 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
                              icon: const Icon(
                                Icons.warning,
                                color: Colors.orange,
                              ),
                            );
                            // 실패 시 바텀시트 닫기
                            Navigator.pop(bottomSheetContext);
                            return;
                          }

                          // 배터리 최적화 권한은 선택적
                          if (!permissions['batteryOptimization']! &&
                              bottomSheetContext.mounted) {
                            Toast(
                              bottomSheetContext,
                              '배터리 최적화 예외 설정이 필요할 수 있습니다. 알람이 정시에 울리지 않으면 설정을 확인해주세요.',
                              icon: const Icon(Icons.info, color: Colors.blue),
                            );

                            // 토스트가 표시될 시간 확보
                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );
                          }

                          // 서버에 기상 시간 등록
                          final wakeUpService = WakeUpService();
                          final success = await wakeUpService.registerWakeTime(
                            selectedTime,
                          );

                          if (!success && bottomSheetContext.mounted) {
                            Toast(
                              bottomSheetContext,
                              '기상 시간 등록에 실패했습니다.',
                              icon: const Icon(Icons.error, color: Colors.red),
                            );
                            // 실패 시 바텀시트 닫기
                            Navigator.pop(bottomSheetContext);
                            return;
                          }

                          // 알람 예약 전에 이전 알람 취소
                          await NotificationService().cancelAllAlarms();

                          // 알람 예약
                          await NotificationService().scheduleWakeUpAlarm(
                            selectedTime,
                          );

                          // 이제 바텀시트를 닫음
                          if (bottomSheetContext.mounted) {
                            Navigator.pop(bottomSheetContext);
                          }

                          // 여기서 알람 설정 성공 토스트와 다이얼로그를 보여줌
                          if (context.mounted) {
                            // 원래 컨텍스트 사용
                            Toast(
                              context,
                              '${WakeUpSection.formatTime(selectedTime)}에 알람이 설정되었습니다.',
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            );

                            // 토스트가 보이도록 약간 대기 후 다이얼로그 표시
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                if (context.mounted) {
                                  showAlarmInfoDialog(context, selectedTime);
                                }
                              },
                            );
                          }
                        } catch (e) {
                          if (bottomSheetContext.mounted) {
                            Toast(
                              bottomSheetContext,
                              '알람 설정 중 오류가 발생했습니다: $e',
                              icon: const Icon(Icons.error, color: Colors.red),
                            );
                            // 오류 발생 시 바텀시트 닫기
                            Navigator.pop(bottomSheetContext);
                          }
                        }
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

  // 시간을 포맷팅하는 static 메서드
  static String formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;

    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$period $displayHour시 $displayMinute분';
  }

  // 알람 설정 다이얼로그를 표시하기 위한 static 메서드
  static void showAlarmInfoDialog(BuildContext context, TimeOfDay wakeUpTime) {
    // 현재 시간 기준으로 알람 예정 시간 계산
    final now = DateTime.now();
    var alarmDate = DateTime(
      now.year,
      now.month,
      now.day,
      wakeUpTime.hour,
      wakeUpTime.minute,
    );

    // 이미 지난 시간이면 내일로 설정
    if (alarmDate.isBefore(now)) {
      alarmDate = alarmDate.add(const Duration(days: 1));
    }

    // 시간 차이 계산
    final difference = alarmDate.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    // 알람 시간 메시지
    final timeMessage =
        hours > 0
            ? '$hours시간 $minutes분 후'
            : minutes > 0
            ? '$minutes분 후'
            : '곧';

    final dayMessage = alarmDate.day != now.day ? '내일' : '오늘';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('알람 설정 완료'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${WakeUpSection.formatTime(wakeUpTime)}에 알람이 설정되었습니다.'),
                const SizedBox(height: 8),
                Text('$dayMessage $timeMessage 알람이 울립니다.'),
                const SizedBox(height: 12),
                const Text('알람이 제대로 작동하려면:'),
                const SizedBox(height: 8),
                const Text('• 알림 권한이 필요합니다'),
                const Text('• 정확한 알람 권한이 필요합니다'),
                const Text('• 기기를 절전 모드에서 제외하는 것이 좋습니다'),
                const SizedBox(height: 12),
                const Text('앱을 종료해도 알람은 작동합니다.'),
                const Text('잠금화면에서 알람 알림을 탭하면 앱의 알람 화면으로 이동합니다.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  @override
  State<WakeUpSection> createState() => _WakeUpSectionState();
}

class _WakeUpSectionState extends State<WakeUpSection> {
  // 알람 활성화 상태
  bool _isAlarmActive = false;
  String _alarmStatusText = '알람 상태 확인 중...';

  // 주기적으로 알람 상태를 확인하기 위한 타이머
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkAlarmStatus();

    // 30초마다 알람 상태 확인 (알람 시간이 지난 경우 자동 갱신)
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkAlarmStatus();
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  // 알람 상태 확인
  Future<void> _checkAlarmStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmHour = prefs.getInt('alarm_hour');
      final alarmMinute = prefs.getInt('alarm_minute');
      final alarmScheduledDate = prefs.getString('alarm_scheduled_date');
      final alarmScheduledAt = prefs.getString('alarm_scheduled_at');

      if (alarmHour != null &&
          alarmMinute != null &&
          alarmScheduledDate != null) {
        // 알람 시간을 DateTime으로 변환
        final scheduledDate = DateTime.parse(alarmScheduledDate);
        final now = DateTime.now();

        // 시간 차이 계산
        final difference = scheduledDate.difference(now);
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;

        // 알람이 미래인지 확인
        if (scheduledDate.isAfter(now)) {
          setState(() {
            _isAlarmActive = true;
            _alarmStatusText =
                hours > 0 ? '$hours시간 $minutes분 후 알람 예정' : '$minutes분 후 알람 예정';
          });
        } else {
          // 알람 시간이 이미 지났는지 확인
          final timeWindow = Duration(minutes: 5);
          final alarmTimeEnd = scheduledDate.add(timeWindow);

          // 알람 시간 이후 5분 이내라면 알람 유효
          if (now.isBefore(alarmTimeEnd)) {
            setState(() {
              _isAlarmActive = true;
              _alarmStatusText = '현재 알람 중';
            });
          } else {
            // 알람 시간이 5분 이상 지난 경우 자동으로 알람 상태 초기화
            setState(() {
              _isAlarmActive = false;
              _alarmStatusText = '설정된 알람 없음';
            });

            // 지난 알람 데이터 삭제
            await _removeExpiredAlarmData();

            // NotificationService를 통해 알람 상태 비활성화
            await NotificationService().deactivateAlarm();
          }
        }
      } else {
        setState(() {
          _isAlarmActive = false;
          _alarmStatusText = '설정된 알람 없음';
        });
      }
    } catch (e) {
      setState(() {
        _isAlarmActive = false;
        _alarmStatusText = '알람 상태 확인 오류';
      });
    }
  }

  // 지난 알람 데이터 삭제
  Future<void> _removeExpiredAlarmData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('alarm_hour');
      await prefs.remove('alarm_minute');
      await prefs.remove('alarm_scheduled_date');
      await prefs.remove('alarm_scheduled_at');
    } catch (e) {
      // 오류 처리
    }
  }

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
          onTap: () => WakeUpSection.showTimePickerBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color:
                  _isAlarmActive
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      color: _isAlarmActive ? AppColors.primary : Colors.grey,
                      size: 40,
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          WakeUpSection.formatTime(myPageProvider.wakeUpTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isAlarmActive ? _alarmStatusText : '알람 설정하기',
                          style: TextStyle(
                            fontSize: 15,
                            color:
                                _isAlarmActive ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  _isAlarmActive ? Icons.alarm_on : Icons.arrow_forward_ios,
                  size: _isAlarmActive ? 24 : 16,
                  color: _isAlarmActive ? AppColors.primary : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 모든 알람 취소
  void _cancelAllAlarms(BuildContext context) async {
    try {
      await NotificationService().cancelAllAlarms();

      // 알람 상태 즉시 변경 (UI 반응성 향상)
      setState(() {
        _isAlarmActive = false;
        _alarmStatusText = '설정된 알람 없음';
      });

      // 백그라운드에서 알람 상태 확인 (데이터 정합성 확보)
      _checkAlarmStatus();

      if (context.mounted) {
        Toast(context, '모든 알람이 취소되었습니다.');
      }
    } catch (e) {
      if (context.mounted) {
        Toast(
          context,
          '알람 취소 오류: $e',
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    }
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
    // 현재 선택된 시간이 오전인지 오후인지 확인
    final isPM = time.hour >= 12;
    final displayHour = time.hour % 12 == 0 ? 12 : time.hour % 12;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // 패딩 약간 줄임
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 오전/오후 선택
          Expanded(
            flex: 3, // AM/PM에 더 많은 공간 할당
            child: Column(
              children: [
                const Text(
                  '오전/오후',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildAmPmSpinner(
                    context,
                    isPM ? 1 : 0, // 0: 오전, 1: 오후
                    (isAm) {
                      int newHour;
                      if (isAm == 0) {
                        // 오전 선택 시
                        newHour = displayHour == 12 ? 0 : displayHour;
                      } else {
                        // 오후 선택 시
                        newHour = displayHour == 12 ? 12 : displayHour + 12;
                      }
                      onTimeChange(
                        TimeOfDay(hour: newHour, minute: time.minute),
                      );
                    },
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
            margin: const EdgeInsets.symmetric(horizontal: 6), // 마진 줄임
          ),

          // 시간 선택 스피너 (1~12시)
          Expanded(
            flex: 2, // 시간에는 적은 공간 할당
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
                    List.generate(12, (index) => index + 1), // 1~12시
                    displayHour,
                    (value) {
                      // 현재 오전/오후 상태 유지하면서 시간만 변경
                      int newHour;
                      if (isPM) {
                        newHour = value == 12 ? 12 : value + 12;
                      } else {
                        newHour = value == 12 ? 0 : value;
                      }
                      onTimeChange(
                        TimeOfDay(hour: newHour, minute: time.minute),
                      );
                    },
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
            margin: const EdgeInsets.symmetric(horizontal: 6), // 마진 줄임
          ),

          // 분 선택 스피너
          Expanded(
            flex: 2, // 분에는 적은 공간 할당
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

  Widget _buildAmPmSpinner(
    BuildContext context,
    int selectedValue, // 0: 오전, 1: 오후
    Function(int) onChanged,
  ) {
    final values = ['오전', '오후'];

    return Container(
      width: double.infinity,
      child: ListWheelScrollView(
        itemExtent: 50,
        perspective: 0.005,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        children: List.generate(2, (index) {
          final isSelected = index == selectedValue;
          return Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(minWidth: 60), // 최소 너비 설정
            child: Text(
              values[index],
              textAlign: TextAlign.center, // 텍스트 중앙 정렬
              style: TextStyle(
                fontSize: isSelected ? 24 : 18, // 약간 작게 조정
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black54,
              ),
            ),
          );
        }),
        controller: FixedExtentScrollController(initialItem: selectedValue),
        onSelectedItemChanged: (index) {
          onChanged(index); // 0이면 오전, 1이면 오후
        },
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
      itemExtent: 50, // 원래 높이로 복원
      perspective: 0.005, // 원래 값으로 복원
      diameterRatio: 1.5, // 원래 값으로 복원
      physics: const FixedExtentScrollPhysics(),
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final value = values[index % values.length];
          final isSelected = value == selectedValue;

          return Container(
            alignment: Alignment.center,
            width: double.infinity, // 너비 확장 유지
            child: FittedBox(
              // FittedBox만 유지
              fit: BoxFit.scaleDown,
              child: Text(
                '$value$suffix',
                style: TextStyle(
                  fontSize: isSelected ? 26 : 20, // 원래 크기로 복원
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : Colors.black54,
                ),
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
