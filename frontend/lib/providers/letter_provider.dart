// /// lib/providers/letter_provider.dart
//
// // Flutter imports:
// import 'package:flutter/material.dart';
//
// // Project imports:
// import 'package:buds/models/letter_content_model.dart';
// import 'package:buds/models/letter_detail_model.dart';
// import 'package:buds/services/letter_service.dart';
//
// class LetterProvider extends ChangeNotifier {
//   final LetterService _service = LetterService();
//
//   // 대화 목록 요약
//   List<LetterDetailModel> _summaries = [];
//   bool _isLoadingSummaries = false;
//   int _currentPage = 0;
//   int _totalPages = 1;
//
//   // 선택된 편지 상세
//   LetterContentModel? _detail;
//   bool _isLoadingDetail = false;
//
//   // getters
//   List<LetterDetailModel> get summaries => _summaries;
//   bool get isLoadingSummaries => _isLoadingSummaries;
//   int get currentPage => _currentPage;
//   int get totalPages => _totalPages;
//   LetterContentModel? get detail => _detail;
//   bool get isLoadingDetail => _isLoadingDetail;
//
//   // 대화 목록(요약) 조회
//   Future<void> fetchSummaries({
//     required int opponentId,
//     int page = 0,
//     int size = 5,
//   }) async {
//     if (_isLoadingSummaries) return;
//     _isLoadingSummaries = true;
//     notifyListeners();
//     try {
//       final list = await _service.fetchLetterDetails(
//         opponentId: opponentId,
//         page: page,
//         size: size,
//       );
//       _summaries = list;
//       _currentPage = page;
//       _totalPages = (list.length == size) ? page + 2 : page + 1;
//     } finally {
//       _isLoadingSummaries = false;
//       notifyListeners();
//     }
//   }
//
//   // 상세 내용 조회
//   Future<void> fetchDetail(int letterId) async {
//     if (_isLoadingDetail) return;
//     _isLoadingDetail = true;
//     notifyListeners();
//     try {
//       _detail = await _service.fetchSingleLetter(letterId);
//     } catch (_) {
//       _detail = null;
//     } finally {
//       _isLoadingDetail = false;
//       notifyListeners();
//     }
//   }
// }

import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/models/letter_content_model.dart';
import 'package:buds/models/letter_detail_model.dart';
import 'package:buds/models/letter_list_model.dart';
import 'package:buds/models/letter_page_model.dart';
import 'package:buds/models/letter_response_model.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/services/activity_service.dart';

class LetterProvider extends ChangeNotifier {
  final LetterService _letterService = LetterService();
  final ActivityService _activityService = ActivityService();

  // 편지 목록
  LetterResponseModel? _letterResponse;
  bool _isLoadingLetters = false;
  int _letterCount = 0;

  // 편지 상세 페이지
  LetterPageModel? _letterPage;
  LetterContentModel? _currentLetter;
  bool _isLoadingPage = false;
  bool _isLoadingDetail = false;
  int _currentPage = 0;
  int _currentLetterIndex = 0;

  // 편지 전송 관련
  bool _isSending = false;
  bool _isInterest = true; // 관심/랜덤 모드 (익명 편지용)

  // Getters
  LetterResponseModel? get letterResponse => _letterResponse;
  bool get isLoadingLetters => _isLoadingLetters;
  int get letterCount => _letterCount;

  LetterPageModel? get letterPage => _letterPage;
  LetterContentModel? get currentLetter => _currentLetter;
  bool get isLoadingPage => _isLoadingPage;
  bool get isLoadingDetail => _isLoadingDetail;
  int get currentPage => _currentPage;
  int get currentLetterIndex => _currentLetterIndex;

  bool get isSending => _isSending;
  bool get isInterest => _isInterest;

  // 편지 목록 조회
  Future<void> fetchLetters() async {
    if (_isLoadingLetters) return;

    _isLoadingLetters = true;
    notifyListeners();

    try {
      final response = await _letterService.fetchLetters();
      _letterResponse = response;
      _letterCount = response.letterCnt;
    } catch (e) {
      print('편지 목록 조회 에러: $e');
    } finally {
      _isLoadingLetters = false;
      notifyListeners();
    }
  }

  // 특정 사용자와의 편지 상세 페이지 조회
  Future<void> fetchLetterDetails({
    required int opponentId,
    int page = 0,
    int size = 5,
  }) async {
    if (_isLoadingPage) return;

    _isLoadingPage = true;
    _currentLetter = null;
    notifyListeners();

    try {
      final response = await _letterService.fetchLetterDetails(
        opponentId: opponentId,
        page: page,
        size: size,
      );

      _letterPage = response;
      _currentPage = page;
      _currentLetterIndex = _letterPage!.letters.length - 1; // 최신 편지부터

      if (_letterPage!.letters.isNotEmpty) {
        await fetchSingleLetter(_letterPage!.letters[0].letterId);
      }
    } catch (e) {
      print('편지 상세 페이지 조회 에러: $e');
    } finally {
      _isLoadingPage = false;
      notifyListeners();
    }
  }

  // 개별 편지 내용 조회
  Future<void> fetchSingleLetter(int letterId) async {
    if (_isLoadingDetail) return;

    _isLoadingDetail = true;
    notifyListeners();

    try {
      final letterContent = await _letterService.fetchSingleLetter(letterId);
      _currentLetter = letterContent;
    } catch (e) {
      print('편지 내용 조회 에러: $e');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // 현재 편지 인덱스 설정 (페이지네이션 내에서)
  void setCurrentLetterIndex(int index) {
    _currentLetterIndex = index;
    if (_letterPage != null && _letterPage!.letters.isNotEmpty) {
      fetchSingleLetter(
        _letterPage!.letters[_letterPage!.letters.length - 1 - index].letterId,
      );
    }
    notifyListeners();
  }

  // 익명 편지 전송
  Future<bool> sendAnonymityLetter(String content) async {
    if (_isSending) return false;

    _isSending = true;
    notifyListeners();

    try {
      final response = await _letterService.sendAnonymityLetter(
        content,
        _isInterest,
      );
      return response;
    } catch (e) {
      print('익명 편지 전송 에러: $e');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // 답장 전송
  Future<bool> sendLetterAnswer(int letterId, String content) async {
    if (_isSending) return false;

    _isSending = true;
    notifyListeners();

    try {
      final response = await _letterService.sendletterAnswer(letterId, content);
      return response;
    } catch (e) {
      print('답장 전송 에러: $e');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // 특정 사용자에게 편지 전송
  Future<bool> sendUserLetter(int userId, String content) async {
    if (_isSending) return false;

    _isSending = true;
    notifyListeners();

    try {
      final response = await _activityService.sendUserLetter(userId, content);
      return response;
    } catch (e) {
      print('특정 사용자 편지 전송 에러: $e');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // 관심/랜덤 모드 토글
  void toggleInterestMode() {
    _isInterest = !_isInterest;
    notifyListeners();
  }
}
