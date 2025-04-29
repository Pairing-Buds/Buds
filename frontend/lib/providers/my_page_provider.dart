import 'package:flutter/material.dart';
import '../screens/character/models/character_data.dart';
import 'character_provider.dart';

/// 마이페이지 상태를 관리하는 프로바이더
class MyPageProvider extends ChangeNotifier {
  final CharacterProvider _characterProvider;

  MyPageProvider(this._characterProvider);

  // 현재 선택된 캐릭터 인덱스
  int get selectedCharacterIndex =>
      _characterProvider.selectedCharacterIndex ?? 0;

  // 현재 선택된 캐릭터 이름
  String get selectedCharacterName =>
      CharacterData.getName(selectedCharacterIndex);

  // 현재 선택된 캐릭터 이미지 경로
  String get selectedCharacterImage =>
      CharacterData.getImage(selectedCharacterIndex);

  // 기상 시간
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay get wakeUpTime => _wakeUpTime;
  set wakeUpTime(TimeOfDay value) {
    _wakeUpTime = value;
    notifyListeners();
  }

  // 걸음 수 관련 속성
  int _currentSteps = 5849;
  int _targetSteps = 6000;

  int get currentSteps => _currentSteps;
  int get targetSteps => _targetSteps;
  double get stepAchievementRate => _currentSteps / _targetSteps;

  void updateSteps(int steps) {
    _currentSteps = steps;
    notifyListeners();
  }

  void updateTargetSteps(int target) {
    _targetSteps = target;
    notifyListeners();
  }

  // 걸음수 포맷팅
  String formatSteps(int steps) {
    return '${steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 보';
  }
}
