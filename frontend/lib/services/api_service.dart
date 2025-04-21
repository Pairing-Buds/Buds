// API 통신 서비스

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  // 싱글턴 패턴
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // 토큰 관리
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // 헤더 생성
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // GET 요청
  Future<dynamic> get(String url) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _getHeaders(),
          )
          .timeout(Duration(milliseconds: ApiConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET 요청 실패: $e');
    }
  }

  // POST 요청
  Future<dynamic> post(String url, {Map<String, dynamic>? data}) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _getHeaders(),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(Duration(milliseconds: ApiConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST 요청 실패: $e');
    }
  }

  // 응답 처리
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      throw Exception('API 오류 (${response.statusCode}): ${response.body}');
    }
  }
}
