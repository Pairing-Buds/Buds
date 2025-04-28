import 'package:flutter/material.dart';

/// 캐릭터 선택 상태를 관리하는 Provider
class CharacterProvider extends ChangeNotifier {
  // 선택된 캐릭터 인덱스 (null이면 선택되지 않음)
  int? _selectedCharacterIndex;

  // 선택된 캐릭터 인덱스 getter
  int? get selectedCharacterIndex => _selectedCharacterIndex;

  // 캐릭터가 선택되었는지 여부
  bool get hasSelectedCharacter => _selectedCharacterIndex != null;

  // 캐릭터 선택
  void selectCharacter(int index) {
    _selectedCharacterIndex = index;
    notifyListeners();
  }

  // 선택된 캐릭터 초기화
  void resetSelectedCharacter() {
    _selectedCharacterIndex = null;
    notifyListeners();
  }
}
