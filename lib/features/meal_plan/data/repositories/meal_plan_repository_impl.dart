import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../models/meal_plan_model.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  final Dio _dio = DioClient.instance;

  @override
  Future<GeneratedMealPlan> generateMealPlan({
    required int dailyCaloriesTarget,
    required List<String> allergies,
    required String goal,
  }) async {
    final response = await _dio.post(
      ApiConstants.generateMenu,
      data: {
        'user': {
          'dailyCaloriesTarget': dailyCaloriesTarget,
          'allergies': allergies,
          'goal': goal,
        },
      },
    );
    final model = GeneratedMealPlanModel.fromJson(
      response.data as Map<String, dynamic>,
    );
    return model.toEntity();
  }
}
