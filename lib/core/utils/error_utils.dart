import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppError {
  final String userMessage;
  final String? technicalDetail;
  final bool isRetryable;

  const AppError({
    required this.userMessage,
    this.technicalDetail,
    this.isRetryable = true,
  });
}

AppError parseError(Object error, {String context = ''}) {
  final tag = context.isNotEmpty ? '[$context]' : '[API]';

  if (error is DioException) {
    final code = error.response?.statusCode;
    final body = error.response?.data?.toString() ?? '';
    debugPrint('$tag DioException status=$code url=${error.requestOptions.uri} body=$body');

    return switch (code) {
      401 => const AppError(
          userMessage: 'Session expirée — veuillez vous reconnecter.',
          isRetryable: false,
        ),
      403 => const AppError(
          userMessage: 'Cette fonctionnalité est réservée aux membres Premium ✨',
          isRetryable: false,
        ),
      429 => const AppError(
          userMessage: 'Trop de requêtes — réessayez dans quelques secondes.',
        ),
      500 => const AppError(
          userMessage: 'Service temporairement indisponible.\nNous travaillons à résoudre le problème.',
        ),
      502 || 503 => const AppError(
          userMessage: 'Service IA indisponible momentanément.\nRéessayez dans quelques instants.',
        ),
      _ => _fromDioType(error, tag),
    };
  }

  debugPrint('$tag Unknown error: $error');
  return AppError(userMessage: 'Une erreur inattendue est survenue.', technicalDetail: error.toString());
}

AppError _fromDioType(DioException e, String tag) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      debugPrint('$tag Timeout: ${e.type}');
      return const AppError(userMessage: 'La connexion a expiré.\nVérifiez votre réseau.');
    case DioExceptionType.connectionError:
      debugPrint('$tag Connection error: ${e.message}');
      return const AppError(userMessage: 'Impossible de joindre le serveur.\nVérifiez votre connexion internet.');
    default:
      debugPrint('$tag DioException type=${e.type} message=${e.message}');
      return const AppError(userMessage: 'Service temporairement indisponible.');
  }
}
