import '../entities/session_feedback.dart';

abstract class CoachRepository {
  Future<bool> sendFeedback(SessionFeedback feedback);
}
