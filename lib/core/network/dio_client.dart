import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  static Dio get instance => _instance;

  static final Dio _instance = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.addAll([
      LogInterceptor(responseBody: true),
      _AuthInterceptor(),
    ]);
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: injecter le token JWT depuis le storage local
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: gestion 401 / refresh token
    handler.next(err);
  }
}
