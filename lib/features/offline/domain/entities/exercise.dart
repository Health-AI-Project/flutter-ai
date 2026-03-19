class Exercise {
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? videoUrl;
  final String muscleGroup;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.videoUrl,
    required this.muscleGroup,
  });
}
