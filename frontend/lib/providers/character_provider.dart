import 'package:flutter/material.dart';
import '../screens/character/models/character_data.dart';

/// 캐릭터 관련 비즈니스 로직을 관리하는 Provider
class CharacterProvider extends ChangeNotifier {
  // 선택된 캐릭터 인덱스 (null이면 선택되지 않음)
  int? _selectedCharacterIndex;

  // 선택된 캐릭터 인덱스 getter
  int? get selectedCharacterIndex => _selectedCharacterIndex;

  // 캐릭터가 선택되었는지 여부
  bool get hasSelectedCharacter => _selectedCharacterIndex != null;

  // 선택된 캐릭터의 이름
  String? get selectedCharacterName =>
      _selectedCharacterIndex != null
          ? CharacterData.getName(_selectedCharacterIndex!)
          : null;

  // 캐릭터 선택
  void selectCharacter(int index) {
    if (index >= 0 && index < CharacterData.characterCount) {
      _selectedCharacterIndex = index;
      notifyListeners();
    }
  }

  // 선택된 캐릭터 초기화
  void resetSelectedCharacter() {
    _selectedCharacterIndex = null;
    notifyListeners();
  }

  // 캐릭터 선택 완료 메시지 생성
  String getSelectionMessage() {
    if (_selectedCharacterIndex == null) return '';
    return '${CharacterData.getName(_selectedCharacterIndex!)}와(과) 함께하게 되었습니다!';
  }
}
