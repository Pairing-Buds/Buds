// Dio를 사용한 API 통신 서비스

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../utils/dio_logging_interceptor.dart';
import 'package:flutter/foundation.dart';

class DioApiService {
  // 싱글턴 패턴
  static final DioApiService _instance = DioApiService._internal();
  factory DioApiService() => _instance;

  late Dio _dio;
  String? _token;

  DioApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 추가 기본 헤더
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
        },
      ),
    );

    // 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 요청 인터셉터
          // 로컬 변수에 토큰이 없으면 SharedPreferences에서 확인
          if (_token == null) {
            await _loadTokenFromStorage();
          }

          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 응답 인터셉터
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // 에러 인터셉터
          return handler.next(error);
        },
      ),
    );

    // 로깅 인터셉터 추가
    _dio.interceptors.add(DioLoggingInterceptor());

    // 추가 디버그 인터셉터 추가
    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            print('🌐 API 요청 시작: ${options.method} ${options.path}');
            print('🌐 요청 헤더: ${options.headers}');
            print('🌐 요청 데이터: ${options.data}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            print('✅ API 응답 성공: ${response.statusCode}');
            print('✅ 응답 데이터: ${response.data}');
            return handler.next(response);
          },
          onError: (DioException e, handler) {
            print('❌ API 오류 발생: ${e.type}');
            print('❌ 오류 메시지: ${e.message}');
            print('❌ 응답 상태 코드: ${e.response?.statusCode}');
            print('❌ 응답 데이터: ${e.response?.data}');
            return handler.next(e);
          },
        ),
      );
    }

    // 초기화 시 토큰 로드
    _loadTokenFromStorage();
  }

  // SharedPreferences에서 토큰 로드
  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(AppConstants.tokenKey);
    } catch (e) {
      print('토큰 로드 실패: $e');
    }
  }

  // 토큰 관리
  Future<void> setToken(String token) async {
    _token = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
    } catch (e) {
      print('토큰 저장 실패: $e');
    }
  }

  Future<void> clearToken() async {
    _token = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
    } catch (e) {
      print('토큰 삭제 실패: $e');
    }
  }

  // GET 요청
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // POST 요청
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // PUT 요청
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // DELETE 요청
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // Dio 에러 처리
  void _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw '연결 시간 초과';
      case DioExceptionType.receiveTimeout:
        throw '응답 시간 초과';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        throw 'API 오류 ($statusCode): $responseData';
      case DioExceptionType.cancel:
        throw '요청이 취소됨';
      default:
        throw '네트워크 오류: ${e.message}';
    }
  }
}
