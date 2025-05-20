import 'package:flutter/material.dart';
import 'package:buds/models/admin_question_model.dart';
import 'package:buds/services/api_service.dart';

class AdminCSProvider extends ChangeNotifier {
  final DioApiService _apiService = DioApiService();
  
  List<Question> _questions = [];
  bool _isLoading = false;
  String? _error;
  
  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 특정 사용자의 문의 목록 조회
  Future<void> fetchUserQuestions(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final res = await _apiService.get('/admin/cs/users/$userId');
      
      if (res.data != null && res.data['resMsg'] != null && res.data['resMsg']['questions'] != null) {
        _questions = (res.data['resMsg']['questions'] as List)
            .map((q) => Question.fromJson(q))
            .toList();
        
        // 날짜 기준 내림차순 정렬
        _questions.sort((a, b) {
          DateTime dateA = DateTime.parse(a.createdAt);
          DateTime dateB = DateTime.parse(b.createdAt);
          return dateB.compareTo(dateA);
        });
      } else {
        _questions = [];
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '문의 상세 조회 실패: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 답변 등록
  Future<bool> submitAnswer(int userId, int questionId, String content) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.post(
        '/admin/cs',
        data: {
          'userId': userId,
          'questionId': questionId,
          'content': content,
        },
      );
      
      await fetchUserQuestions(userId); // 데이터 새로고침
      return true;
    } catch (e) {
      _error = '답변 등록 실패: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 답변 수정
  Future<bool> updateAnswer(int userId, int answerId, String content) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.patch(
        '/admin/cs',
        data: {
          'answerId': answerId,
          'content': content,
        },
      );
      
      await fetchUserQuestions(userId); // 데이터 새로고침
      return true;
    } catch (e) {
      _error = '답변 수정 실패: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 답변 삭제
  Future<bool> deleteAnswer(int userId, int answerId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.delete(
        '/admin/cs',
        data: {
          'answerId': answerId
        },
      );
      
      await fetchUserQuestions(userId); // 데이터 새로고침
      return true;
    } catch (e) {
      _error = '답변 삭제 실패: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 