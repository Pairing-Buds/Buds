import 'package:flutter/material.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/models/letter_detail_model.dart';
import 'package:buds/models/letter_response_model.dart';

class LetterProvider extends ChangeNotifier {
  final LetterService _letterService = LetterService();

  List<LetterDetailModel> _letters = []; // 편지 목록 (개별 편지)
  bool _isLoading = false;
  int _currentPage = 0;
  int _totalPages = 1;
  int _letterCount = 0; // 전체 편지 수 (LetterResponseModel에서 받아옴)

  List<LetterDetailModel> get letters => _letters;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get letterCount => _letterCount; // 전체 편지 수 getter

  /// 편지 목록 초기화
  void resetLetters() {
    _letters = [];
    _currentPage = 0;
    _totalPages = 1;
    _letterCount = 0;
    notifyListeners();
  }

  /// 편지 목록 조회 (편지 수는 LetterResponseModel에서만 확인)
  Future<void> fetchLetters(int opponentId) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      // 전체 응답을 LetterResponseModel로 받아옴
      final response = await _letterService.fetchLetters();
      _letterCount = response.letterCnt; // 전체 편지 수 저장

      // 특정 사용자와 주고 받은 편지만 필터링
      _letters = response.letters
          .where((letter) => letter.userId == opponentId)
          .map((letter) => LetterDetailModel(
        letterId: letter.letterId,
        senderName: letter.userName,
        createdAt: letter.lastLetterDate,
        status: letter.lastLetterStatus,
        received: letter.received,
      ))
          .toList();

      _totalPages = (_letterCount / 5).ceil();
    } catch (e) {
      print('편지 목록 조회 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 페이지 변경
  void setPage(int page) {
    if (page < 0 || page >= _totalPages) return;
    _currentPage = page;
    notifyListeners();
  }

  /// 편지 상세 조회 (LetterDetailModel에서 조회)
  Future<LetterDetailModel?> fetchLetterDetail(int letterId) async {
    try {
      return _letters.firstWhere((letter) => letter.letterId == letterId);
    } catch (e) {
      print('편지 상세 조회 오류: $e');
      return null;
    }
  }

  /// 편지 스크랩 토글
  Future<void> toggleScrap(int letterId) async {
    try {
      await _letterService.toggleScrap(letterId);
      notifyListeners();
    } catch (e) {
      print('스크랩 토글 오류: $e');
    }
  }
}
