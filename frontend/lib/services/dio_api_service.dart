// Dio를 사용한 API 통신 서비스

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/dio_logging_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class DioApiService {
  // 싱글턴 패턴
  static final DioApiService _instance = DioApiService._internal();
  factory DioApiService() => _instance;

  late Dio _dio;
  late PersistCookieJar _cookieJar;

  DioApiService._internal() {
    _initDio();
  }

  Future<void> _initDio() async {
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

    // 쿠키 자동 관리 설정
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDocPath = appDocDir.path;
      _cookieJar = PersistCookieJar(
        storage: FileStorage("$appDocPath/.cookies/"),
      );
      _dio.interceptors.add(CookieManager(_cookieJar));

      if (kDebugMode) {
        print('쿠키 자동 관리 설정 완료. 저장 경로: $appDocPath/.cookies/');
      }
    } catch (e) {
      if (kDebugMode) {
        print('쿠키 자동 관리 설정 실패: $e');
      }
      // 쿠키 매니저 설정 실패 시 메모리에만 저장하는 기본 쿠키 자르 사용
      _cookieJar = PersistCookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar));
    }

    // 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 요청 인터셉터
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
            // 쿠키 확인
            _printCookies(response.requestOptions.uri.toString());
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
  }

  // 디버깅용 쿠키 출력 함수
  void _printCookies(String url) async {
    if (kDebugMode) {
      final cookies = await _cookieJar.loadForRequest(Uri.parse(url));
      print('🍪 저장된 쿠키: $cookies');
    }
  }

  // 모든 쿠키 삭제
  Future<void> clearCookies() async {
    try {
      await _cookieJar.deleteAll();
      if (kDebugMode) {
        print('모든 쿠키가 삭제되었습니다.');
      }
    } catch (e) {
      print('쿠키 삭제 실패: $e');
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

  // DioException 처리
  void _handleDioError(DioException e) {
    if (kDebugMode) {
      print('Dio 오류: ${e.type}');
      print('요청 URL: ${e.requestOptions.path}');
      print('상태 코드: ${e.response?.statusCode}');
      print('응답 데이터: ${e.response?.data}');
    }
  }
}
