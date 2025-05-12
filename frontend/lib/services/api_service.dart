// Dio를 사용한 API 통신 서비스

// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../constants/api_constants.dart';
import '../utils/dio_logging_interceptor.dart';

class DioApiService {
  // 싱글턴 패턴
  static final DioApiService _instance = DioApiService._internal();
  factory DioApiService() => _instance;

  late Dio _dio;
  PersistCookieJar? _cookieJar;
  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  DioApiService._internal() {
    _initDio();
  }

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    if (!_initCompleter.isCompleted) {
      await _initCompleter.future;
    }
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
      final cookiePath = "$appDocPath/.cookies/";

      // 쿠키 디렉토리 확인 및 생성
      final cookieDir = Directory(cookiePath);
      if (!await cookieDir.exists()) {
        await cookieDir.create(recursive: true);
      }

      _cookieJar = PersistCookieJar(
        storage: FileStorage(cookiePath),
        ignoreExpires: false, // 만료된 쿠키 자동 처리
      );

      _dio.interceptors.add(CookieManager(_cookieJar!));

      if (kDebugMode) {
        print('쿠키 자동 관리 설정 완료. 저장 경로: $cookiePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('쿠키 자동 관리 설정 실패: $e');
      }
      // 쿠키 매니저 설정 실패 시 메모리에만 저장하는 기본 쿠키 자르 사용
      _cookieJar = PersistCookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar!));
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

    _isInitialized = true;
    _initCompleter.complete();
  }

  // 디버깅용 쿠키 출력 함수
  void _printCookies(String url) async {
    if (kDebugMode && _cookieJar != null) {
      try {
        final cookies = await _cookieJar!.loadForRequest(Uri.parse(url));
        print('🍪 저장된 쿠키: $cookies');
      } catch (e) {
        print('쿠키 로드 실패: $e');
      }
    }
  }

  // 모든 쿠키 삭제
  Future<void> clearCookies() async {
    try {
      await ensureInitialized();
      if (_cookieJar != null) {
        await _cookieJar!.deleteAll();
        if (kDebugMode) {
          print('모든 쿠키가 삭제되었습니다.');
        }
      }
    } catch (e) {
      print('쿠키 삭제 실패: $e');
    }
  }

  // 앱 시작 시 저장된 쿠키 확인
  Future<bool> checkSavedCookies() async {
    try {
      await ensureInitialized();
      if (_cookieJar == null) {
        if (kDebugMode) {
          print('쿠키 자르가 초기화되지 않았습니다.');
        }
        return false;
      }

      final cookies = await _cookieJar!.loadForRequest(
        Uri.parse(ApiConstants.baseUrl),
      );

      if (kDebugMode) {
        print('🍪 앱 시작 시 저장된 쿠키 확인: $cookies');
      }

      // 액세스 토큰이나 리프레시 토큰이 있는지 확인
      final hasAuthCookies = cookies.any(
        (cookie) =>
            cookie.name == 'access_token' || cookie.name == 'refresh_token',
      );

      if (kDebugMode) {
        print('인증 쿠키 존재 여부: $hasAuthCookies');
      }

      return hasAuthCookies;
    } catch (e) {
      if (kDebugMode) {
        print('저장된 쿠키 확인 중 오류: $e');
      }
      return false;
    }
  }

  // GET 요청
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await ensureInitialized();
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
      await ensureInitialized();
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
      await ensureInitialized();
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
      await ensureInitialized();
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

  // PATCH 요청
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await ensureInitialized();
      final response = await _dio.patch(
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
