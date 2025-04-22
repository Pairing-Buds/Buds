// Dio를 사용한 API 통신 서비스

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/dio_logging_interceptor.dart';

class DioApiService {
  // 싱글턴 패턴
  static final DioApiService _instance = DioApiService._internal();
  factory DioApiService() => _instance;

  late Dio _dio;

  DioApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 요청 인터셉터
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
  }

  // 토큰 관리
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // GET 요청
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);

      return response.data;
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
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data;
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
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data;
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
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data;
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
