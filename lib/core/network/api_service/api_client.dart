/* //============================= new code ===================
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'token_meneger.dart';

class ApiClient {
  final Dio dio;
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshCompleters = [];

  ApiClient(String baseUrl)
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 90),
          validateStatus: (status) => status != null && status < 500,
        ),
      ) {
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true, responseHeader: false, error: true, compact: true),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print("➡ [REQUEST] ${options.method} ${options.uri}");
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print("[RESPONSE] ${response.statusCode} ${response.data}");
          }
          return handler.next(response);
        },
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          if (err.response?.statusCode == 401) {
            final currentToken = await TokenManager.getToken();
            if (currentToken != null) {
              try {
                await _handleRefresh();

                final clonedRequest = err.requestOptions;
                final newToken = await TokenManager.getToken();
                clonedRequest.headers['Authorization'] = 'Bearer $newToken';

                final clonedResponse = await dio.fetch(clonedRequest);
                return handler.resolve(clonedResponse);
              } catch (refreshError) {
                // Refresh fail → clear token & reject
                await TokenManager.clearToken();
                // Optional: Get.offAll(LoginScreen());
                return handler.reject(err);
              }
            }
          }

          return handler.reject(err);
        },
      ),
    );
  }

  /// Refresh token logic – race condition prevent
  Future<void> _handleRefresh() async {
    if (_isRefreshing) {
      // Already refreshing → wait for it to finish
      final completer = Completer<void>();
      _refreshCompleters.add(completer);
      await completer.future;
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await dio.post('/auth/refresh-token', data: {'refreshToken': refreshToken}, cancelToken: CancelToken());

      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid refresh token response');
      }

      await TokenManager.accessToken(data['accessToken'] as String);
      final newRefreshToken = data['refreshToken'] as String?;
      await TokenManager.refreshToken(newRefreshToken ?? refreshToken);

      // Complete all waiting requests
      for (var completer in _refreshCompleters) {
        completer.complete();
      }
      _refreshCompleters.clear();
    } catch (e) {
      print('Refresh failed: $e');
      await TokenManager.clearToken();
      // Optional: logout logic here
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  // API methods
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }
}
 */


import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'token_meneger.dart';

class ApiClient {
  final Dio dio;

  bool _isRefreshing = false;
  final List<Completer<void>> _refreshCompleters = [];

  // ✅ refresh এর জন্য আলাদা dio (no interceptors)
  late final Dio _refreshDio;

  ApiClient(String baseUrl)
      : dio = Dio(
          BaseOptions(
            baseUrl: _normalizeBaseUrl(baseUrl),
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 90),
            // ✅ 200-299 ছাড়া সব error => onError এ যাবে
            validateStatus: (status) =>
                status != null && status >= 200 && status < 300,
          ),
        ) {
    final normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: normalizedBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 90),
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ auth endpoints এ token attach না করাই safe
          final isAuthEndpoint = options.path.contains('/auth/login') ||
              options.path.contains('/auth/refresh-token');

          if (!isAuthEndpoint) {
            final token = await TokenManager.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          if (kDebugMode) {
            print("➡ [REQUEST] ${options.method} ${options.uri}");
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print("[RESPONSE] ${response.statusCode} ${response.data}");
          }
          return handler.next(response);
        },
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          final status = err.response?.statusCode;
          final path = err.requestOptions.path;

          final isAuthEndpoint = path.contains('/auth/login') ||
              path.contains('/auth/refresh-token');

          // ✅ auth endpoints এ refresh trigger বন্ধ (loop prevent)
          if (status == 401 && !isAuthEndpoint) {
            final currentToken = await TokenManager.getToken();
            if (currentToken != null) {
              try {
                await _handleRefresh();

                // ✅ retry request safely
                final ro = err.requestOptions;
                final newToken = await TokenManager.getToken();

                final retryResponse = await dio.request(
                  ro.path,
                  data: ro.data,
                  queryParameters: ro.queryParameters,
                  options: Options(
                    method: ro.method,
                    headers: {
                      ...ro.headers,
                      'Authorization': 'Bearer $newToken',
                    },
                    responseType: ro.responseType,
                    contentType: ro.contentType,
                    followRedirects: ro.followRedirects,
                    receiveDataWhenStatusError: ro.receiveDataWhenStatusError,
                    validateStatus: ro.validateStatus,
                  ),
                );

                return handler.resolve(retryResponse);
              } catch (_) {
                await TokenManager.clearToken();
                return handler.reject(err);
              }
            }
          }

          return handler.reject(err);
        },
      ),
    );
  }

  /// Refresh token logic – race condition prevent
  Future<void> _handleRefresh() async {
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshCompleters.add(completer);
      await completer.future;
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // ✅ refresh call uses _refreshDio (no interceptors)
      final response = await _refreshDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      final data = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>?;

      if (data == null) {
        throw Exception('Invalid refresh token response');
      }

      await TokenManager.accessToken(data['accessToken'] as String);
      final newRefreshToken = data['refreshToken'] as String?;
      await TokenManager.refreshToken(newRefreshToken ?? refreshToken);

      // ✅ Complete all waiting requests
      for (final completer in _refreshCompleters) {
        if (!completer.isCompleted) completer.complete();
      }
      _refreshCompleters.clear();
    } catch (e) {
      // ✅ Fail all waiting requests (avoid hanging)
      for (final completer in _refreshCompleters) {
        if (!completer.isCompleted) completer.completeError(e);
      }
      _refreshCompleters.clear();

      await TokenManager.clearToken();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  // API methods
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }

  static String _normalizeBaseUrl(String rawBaseUrl) {
    final trimmed = rawBaseUrl.trim();
    if (trimmed.isEmpty) return trimmed;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) return trimmed;

    var host = uri.host;
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (host == 'localhost' || host == '127.0.0.1')) {
      host = '10.0.2.2';
    }

    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
      query: uri.hasQuery ? uri.query : null,
      fragment: uri.hasFragment ? uri.fragment : null,
    ).toString();
  }
}
