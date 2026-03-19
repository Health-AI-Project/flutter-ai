import 'package:dio/dio.dart';
import '../../domain/entities/meal_analysis.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/image_utils.dart';
import '../models/meal_analysis_model.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final Dio _dio = DioClient.instance;

  @override
  Future<MealAnalysis> analyzeMeal({
    required String imagePath,
    required String userId,
  }) async {
    final compressedPath = await ImageUtils.compress(imagePath);

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          compressedPath,
          filename: 'meal.jpg',
        ),
        'userId': userId,
      });

      final response = await _dio.post(
        ApiConstants.uploadMeal,
        data: formData,
      );

      final model =
          MealAnalysisModel.fromJson(response.data as Map<String, dynamic>);
      return model.toEntity();
    } finally {
      await ImageUtils.deleteTemp(compressedPath);
    }
  }
}
