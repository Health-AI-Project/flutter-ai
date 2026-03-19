import '../../domain/entities/session_feedback.dart';

class SessionFeedbackModel {
  final String userId;
  final String sessionDay;
  final int rpe;
  final String completedAt;

  const SessionFeedbackModel({
    required this.userId,
    required this.sessionDay,
    required this.rpe,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'sessionDay': sessionDay,
        'rpe': rpe,
        'completedAt': completedAt,
      };

  factory SessionFeedbackModel.fromEntity(SessionFeedback entity) {
    return SessionFeedbackModel(
      userId: entity.userId,
      sessionDay: entity.sessionDay,
      rpe: entity.rpe,
      completedAt: entity.completedAt.toIso8601String(),
    );
  }
}
