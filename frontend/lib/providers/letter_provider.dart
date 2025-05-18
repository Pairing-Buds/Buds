/// lib/providers/letter_provider.dart

// Flutter imports:
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

  // 편지 내용 캐시 추가
  final Map<int, LetterContentModel> _letterContentCache = {};

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

  // 특정 사용자와의 편지 상세 페이지 조회 및 내용 캐싱
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

      // 받아온 편지 목록을 createdAt 기준으로 최신순 정렬
      if (response.letters.isNotEmpty) {
        final sortedLetters = List<LetterDetailModel>.from(response.letters);
        sortedLetters.sort(
          (a, b) => DateTime.parse(
            b.createdAt,
          ).compareTo(DateTime.parse(a.createdAt)),
        );

        _letterPage = LetterPageModel(
          opponentId: response.opponentId,
          opponentName: response.opponentName,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          letters: sortedLetters,
        );
      } else {
        _letterPage = response;
      }

      _currentPage = page;
      _currentLetterIndex = 0; // 정렬 후 첫 번째 항목이 최신 편지

      // 페이지의 첫 번째 편지 로드 (단일 요청)
      if (_letterPage!.letters.isNotEmpty) {
        await fetchSingleLetter(_letterPage!.letters[0].letterId);

        // 백그라운드에서 페이지의 나머지 편지 내용 미리 로드 (캐싱)
        _prefetchPageLetterContents();
      }
    } catch (e) {
      print('편지 상세 페이지 조회 에러: $e');
    } finally {
      _isLoadingPage = false;
      notifyListeners();
    }
  }

  // 현재 페이지의 모든 편지 내용을 백그라운드에서 미리 로드 (최적화)
  Future<void> _prefetchPageLetterContents() async {
    if (_letterPage == null || _letterPage!.letters.isEmpty) return;

    for (int i = 0; i < _letterPage!.letters.length; i++) {
      final letterId = _letterPage!.letters[i].letterId;
      // 첫 번째 편지는 이미 로드했으므로 건너뜀
      if (i != 0 && !_letterContentCache.containsKey(letterId)) {
        try {
          final content = await _letterService.fetchSingleLetter(letterId);
          _letterContentCache[letterId] = content;
        } catch (e) {
          print('편지 ${letterId} 미리 로드 실패: $e');
        }
      }
    }
  }

  // 개별 편지 내용 조회 (캐시 활용)
  Future<void> fetchSingleLetter(int letterId) async {
    if (_isLoadingDetail) return;

    // 캐시에 있으면 캐시에서 가져옴
    if (_letterContentCache.containsKey(letterId)) {
      _currentLetter = _letterContentCache[letterId];
      notifyListeners();
      return;
    }

    _isLoadingDetail = true;
    notifyListeners();

    try {
      final letterContent = await _letterService.fetchSingleLetter(letterId);
      _currentLetter = letterContent;
      // 캐시에 저장
      _letterContentCache[letterId] = letterContent;
    } catch (e) {
      print('편지 내용 조회 에러: $e');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // 현재 편지 인덱스 설정 (페이지네이션 내에서) - 캐시 활용
  void setCurrentLetterIndex(int index) {
    _currentLetterIndex = index;
    if (_letterPage != null && _letterPage!.letters.isNotEmpty) {
      final letterId = _letterPage!.letters[index].letterId;
      fetchSingleLetter(letterId);
    }
    notifyListeners();
  }

  // 캐시 관련 메서드 추가
  bool hasLetterInCache(int letterId) {
    return _letterContentCache.containsKey(letterId);
  }

  LetterContentModel getLetterFromCache(int letterId) {
    return _letterContentCache[letterId]!;
  }

  void clearLetterCache() {
    _letterContentCache.clear();
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
