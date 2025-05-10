/// lib/providers/letter_provider.dart
import 'package:flutter/material.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/models/letter_detail_model.dart';
import 'package:buds/models/letter_content_model.dart';

class LetterProvider extends ChangeNotifier {
  final LetterService _service = LetterService();

  // 대화 목록 요약
  List<LetterDetailModel> _summaries = [];
  bool _isLoadingSummaries = false;
  int _currentPage = 0;
  int _totalPages = 1;

  // 선택된 편지 상세
  LetterContentModel? _detail;
  bool _isLoadingDetail = false;

  // getters
  List<LetterDetailModel> get summaries => _summaries;
  bool get isLoadingSummaries => _isLoadingSummaries;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  LetterContentModel? get detail => _detail;
  bool get isLoadingDetail => _isLoadingDetail;

  // 대화 목록(요약) 조회
  Future<void> fetchSummaries({
    required int opponentId,
    int page = 0,
    int size = 5,
  }) async {
    if (_isLoadingSummaries) return;
    _isLoadingSummaries = true;
    notifyListeners();
    try {
      final list = await _service.fetchLetterDetails(
        opponentId: opponentId,
        page: page,
        size: size,
      );
      _summaries = list;
      _currentPage = page;
      _totalPages = (list.length == size) ? page + 2 : page + 1;
    } finally {
      _isLoadingSummaries = false;
      notifyListeners();
    }
  }

  // 상세 내용 조회
  Future<void> fetchDetail(int letterId) async {
    if (_isLoadingDetail) return;
    _isLoadingDetail = true;
    notifyListeners();
    try {
      _detail = await _service.fetchSingleLetter(letterId);
    } catch (_) {
      _detail = null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }
}