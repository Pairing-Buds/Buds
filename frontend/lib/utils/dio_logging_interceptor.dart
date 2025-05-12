// Dio 로깅 인터셉터

// Dart imports:
import 'dart:developer' as developer;

// Package imports:
import 'package:dio/dio.dart';

class DioLoggingInterceptor extends Interceptor {
  final bool request;
  final bool requestHeader;
  final bool requestBody;
  final bool responseHeader;
  final bool responseBody;
  final bool error;

  DioLoggingInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = true,
    this.responseBody = true,
    this.error = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (request) {
      _printRequestInfo(options);
      if (requestHeader) {
        _printMapAsTable(options.headers, header: 'Headers');
        _printMapAsTable(options.queryParameters, header: 'Query Parameters');
      }
      if (requestBody && options.data != null) {
        developer.log('Body: ${options.data}', name: 'HTTP-REQUEST');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (responseBody) {
      developer.log(
        '<-- ${response.statusCode} ${response.requestOptions.path}',
        name: 'HTTP-RESPONSE',
      );
      developer.log('Response: ${response.data}', name: 'HTTP-RESPONSE');
      _printResponseInfo(response);
    }
    if (responseHeader) {
      _printMapAsTable(response.headers.map, header: 'Headers');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      developer.log(
        '!!! 에러: ${err.message}, 코드: ${err.response?.statusCode}',
        name: 'HTTP-ERROR',
      );
      if (err.response != null) {
        _printResponseInfo(err.response!);
      }
      developer.log('!!! ${err.stackTrace}', name: 'HTTP-ERROR');
    }

    super.onError(err, handler);
  }

  void _printRequestInfo(RequestOptions options) {
    developer.log('--> ${options.method} ${options.uri}', name: 'HTTP-REQUEST');
  }

  void _printResponseInfo(Response response) {
    developer.log(
      '<-- ${response.statusCode} ${response.requestOptions.uri}',
      name: 'HTTP-RESPONSE',
    );
  }

  void _printMapAsTable(Map<String, dynamic>? map, {String? header}) {
    if (map != null && map.isNotEmpty) {
      developer.log('$header:', name: 'HTTP');
      map.forEach((key, value) {
        developer.log('  $key: $value', name: 'HTTP');
      });
    }
  }
}
