import 'package:flutter/foundation.dart';

import '../../domain/entities/session_feedback.dart';
import '../../domain/repositories/coach_repository.dart';

class CoachRepositoryMock implements CoachRepository {
  @override
  Future<bool> sendFeedback(SessionFeedback feedback) async {
    await Future.delayed(const Duration(milliseconds: 800));
    debugPrint('Mock feedback envoyé — RPE: ${feedback.rpe}, Jour: ${feedback.sessionDay}');
    return true;
  }
}
