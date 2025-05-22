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
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }

  void _printRequestInfo(RequestOptions options) {}

  void _printResponseInfo(Response response) {}

  void _printMapAsTable(Map<String, dynamic>? map, {String? header}) {}
}
