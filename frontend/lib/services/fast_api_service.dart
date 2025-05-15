// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:buds/constants/api_constants.dart';

class FastApiService {
  late final Dio _dio;
  late final PersistCookieJar _cookieJar;
  late final Future<void> _init;

  FastApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.fastApiUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _init = _initializeCookieJar();
  }

  Future<void> _initializeCookieJar() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/.cookies/';
    _cookieJar = PersistCookieJar(storage: FileStorage(path));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final cookies = await _cookieJar.loadForRequest(Uri.parse(ApiConstants.fastApiUrl));
        final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');
        options.headers['Cookie'] = cookieHeader;
        print('🍪 FastAPI 요청에 붙인 쿠키: $cookieHeader');
        handler.next(options);
      },
    ));
  }

  Future<void> ensureInitialized() => _init;

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    await ensureInitialized();
    return await _dio.post(path, data: data, options: options);
  }
}
