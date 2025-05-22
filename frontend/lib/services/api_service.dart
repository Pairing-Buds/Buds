// Dio를 사용한 API 통신 서비스

// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../constants/api_constants.dart';
import '../utils/dio_logging_interceptor.dart';
import '../widgets/common_dialog.dart';

// 401 에러 처리를 위한 전역 컨트롤러
final StreamController<bool> unauthorizedController =
    StreamController<bool>.broadcast();

// StreamController가 닫혔는지 확인하는 플래그를 클래스 내부 스태틱 변수로 이동
class DioApiService {
  // 싱글턴 패턴
  static final DioApiService _instance = DioApiService._internal();
  factory DioApiService() => _instance;

  // 컨트롤러 상태 관리를 위한 스태틱 변수
  static bool isUnauthorizedControllerClosed = false;

  late Dio _dio;
  PersistCookieJar? _cookieJar;
  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  // 중복 로그인 다이얼로그 표시 방지를 위한 플래그
  bool _isShowingDuplicateLoginDialog = false;

  DioApiService._internal() {
    _initDio();
  }

  // 컨트롤러 상태 제어 메서드들
  static Future<void> closeUnauthorizedController() async {
    try {
      if (!isUnauthorizedControllerClosed) {
        await unauthorizedController.close();
        isUnauthorizedControllerClosed = true;
      }
    } catch (e) {
      isUnauthorizedControllerClosed = true;
    }
  }

  static void resetUnauthorizedController() {
    isUnauthorizedControllerClosed = false;
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
    } catch (e) {
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
          // 401 에러 처리 - 중복 로그인 또는 토큰 만료
          if (error.response?.statusCode == 401) {
            // 중복 로그인 처리를 위한 이벤트 발생 (컨트롤러가 닫히지 않았을 때만)
            if (!isUnauthorizedControllerClosed) {
              try {
                unauthorizedController.add(true);
              } catch (e) {
                // 컨트롤러가 닫혔거나 다른 에러 발생 시
                isUnauthorizedControllerClosed = true;
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 로깅 인터셉터 추가
    _dio.interceptors.add(DioLoggingInterceptor());

    _isInitialized = true;
    _initCompleter.complete();
  }

  // 중복 로그인 처리 함수
  void showDuplicateLoginDialog(BuildContext context) {
    // 이미 다이얼로그가 표시중이면 중복 표시 방지
    if (_isShowingDuplicateLoginDialog) return;
    _isShowingDuplicateLoginDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CommonDialog(
            title: "중복 로그인 감지",
            description: "다른 기기에서 로그인되어 로그아웃 됩니다.",
            cancelText: "확인",
            confirmText: "",
            onCancel: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              // 로그인 화면으로 이동
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
              // 쿠키 삭제
              clearCookies();
              _isShowingDuplicateLoginDialog = false;
            },
            onConfirm: () {},
          ),
    );
  }

  // 디버깅용 쿠키 출력 함수
  void _printCookies(String url) async {}

  // 모든 쿠키 삭제
  Future<void> clearCookies() async {
    try {
      await ensureInitialized();
      if (_cookieJar != null) {
        await _cookieJar!.deleteAll();
      }
    } catch (e) {}
  }

  // 앱 시작 시 저장된 쿠키 확인
  Future<bool> checkSavedCookies() async {
    try {
      await ensureInitialized();
      if (_cookieJar == null) {
        return false;
      }

      final cookies = await _cookieJar!.loadForRequest(
        Uri.parse(ApiConstants.baseUrl),
      );

      // 액세스 토큰이나 리프레시 토큰이 있는지 확인
      final hasAuthCookies = cookies.any(
        (cookie) =>
            cookie.name == 'access_token' || cookie.name == 'refresh_token',
      );

      return hasAuthCookies;
    } catch (e) {
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
  void _handleDioError(DioException e) {}
}
