import 'package:isar/isar.dart';

part 'exercise_isar.g.dart';

@embedded
class ExerciseIsar {
  late String name;
  late int sets;
  late int reps;
  late int restSeconds;
  String? videoUrl;
  late String muscleGroup;
}
