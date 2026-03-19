class SessionFeedback {
  final String userId;
  final String sessionDay;
  final int rpe;
  final DateTime completedAt;

  const SessionFeedback({
    required this.userId,
    required this.sessionDay,
    required this.rpe,
    required this.completedAt,
  });
}
