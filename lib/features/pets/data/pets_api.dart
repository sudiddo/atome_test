import 'package:dio/dio.dart';
import '../../../core/networking/dio_client.dart';
import 'pet_models.dart';

class PetsApi {
  final Dio _dio;

  PetsApi() : _dio = DioClient.createDio();

  Future<List<Pet>> findPetsByStatus(String status) async {
    try {
      final response = await _dio.get(
        '/pet/findByStatus',
        queryParameters: {'status': status},
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Pet.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch pets by status: ${e}');
    }
  }

  Future<Pet> getPetById(int id) async {
    try {
      final response = await _dio.get('/pet/$id');
      // Check if response data is a Map (JSON) or String (plain text error)
      if (response.data is Map<String, dynamic>) {
        return Pet.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Failed to fetch pet: ${e}');
    } catch (e) {
      // Handle JSON parsing errors and other exceptions
      if (e.toString().contains('Pet not found') ||
          e.toString().contains('SyntaxError')) {
        throw Exception('Pet not found');
      }
      throw Exception('Failed to fetch pet: ${e.toString()}');
    }
  }

  Future<Pet> createPet(Pet pet) async {
    try {
      final response = await _dio.post('/pet', data: pet.toJson());
      // Check if response data is a Map (JSON) or String (plain text error)
      if (response.data is Map<String, dynamic>) {
        return Pet.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create pet: ${e}');
    } catch (e) {
      // Handle JSON parsing errors and other exceptions
      throw Exception('Failed to create pet: ${e.toString()}');
    }
  }

  Future<Pet> updatePet(Pet pet) async {
    try {
      final response = await _dio.put('/pet', data: pet.toJson());
      // Check if response data is a Map (JSON) or String (plain text error)
      if (response.data is Map<String, dynamic>) {
        return Pet.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Failed to update pet: ${e}');
    } catch (e) {
      // Handle JSON parsing errors and other exceptions
      if (e.toString().contains('Pet not found') ||
          e.toString().contains('SyntaxError')) {
        throw Exception('Pet not found');
      }
      throw Exception('Failed to update pet: ${e.toString()}');
    }
  }

  Future<void> deletePet(int id) async {
    try {
      await _dio.delete(
        '/pet/$id',
        options: Options(
          responseType: ResponseType.plain, // Handle plain text response
        ),
      );
      // DELETE operation successful - API returns "Pet deleted" as plain text
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Failed to delete pet: ${e}');
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('Failed to delete pet: ${e.toString()}');
    }
  }
}
