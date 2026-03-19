import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/session_feedback.dart';
import '../../domain/repositories/coach_repository.dart';
import '../models/session_feedback_model.dart';

class CoachRepositoryImpl implements CoachRepository {
  final Dio _dio = DioClient.instance;

  @override
  Future<bool> sendFeedback(SessionFeedback feedback) async {
    try {
      final model = SessionFeedbackModel.fromEntity(feedback);
      final response = await _dio.post(
        '/api/coach/feedback',
        data: model.toJson(),
      );
      return response.data['success'] == true;
    } catch (e, stackTrace) {
      debugPrint('ERREUR sendFeedback : $e');
      debugPrint('Stack : $stackTrace');
      return false;
    }
  }
}
