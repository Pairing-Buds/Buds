import 'package:flutter/material.dart';
import '../screens/character/models/character_data.dart';
import '../services/dio_api_service.dart';
import '../constants/api_constants.dart';
import 'package:dio/dio.dart';

/// 캐릭터 관련 비즈니스 로직을 관리하는 Provider
class CharacterProvider extends ChangeNotifier {
  // 선택된 캐릭터 인덱스 (null이면 선택되지 않음)
  int? _selectedCharacterIndex;

  // 사용자 닉네임
  String _nickname = '';

  // API 서비스 인스턴스
  final _apiService = DioApiService();

  // 선택된 캐릭터 인덱스 getter
  int? get selectedCharacterIndex => _selectedCharacterIndex;

  // 캐릭터가 선택되었는지 여부
  bool get hasSelectedCharacter => _selectedCharacterIndex != null;

  // 선택된 캐릭터의 이름
  String? get selectedCharacterName =>
      _selectedCharacterIndex != null
          ? CharacterData.getName(_selectedCharacterIndex!)
          : null;

  // 사용자 닉네임 getter
  String get nickname => _nickname;

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

  // 랜덤 닉네임 요청
  Future<String?> requestRandomNickname() async {
    try {
      final response = await _apiService.get(ApiConstants.randomNicknameUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        _nickname = data['resMsg']['username'] ?? '';
        notifyListeners();
        return _nickname;
      }
      return null;
    } on DioException catch (e) {
      print('랜덤 닉네임 요청 오류: ${e.message}');
      return null;
    } catch (e) {
      print('랜덤 닉네임 요청 중 예상치 못한 오류: $e');
      return null;
    }
  }

  // 닉네임 설정
  void setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }

  // 회원가입 완료 정보 반환
  Map<String, dynamic> getUserRegistrationData() {
    return {
      'username': _nickname,
      'userCharacter': selectedCharacterName ?? '',
    };
  }
}
