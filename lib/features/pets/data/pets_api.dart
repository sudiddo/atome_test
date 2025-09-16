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
      return data.map((json) => Pet.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch pets by status: ${e.message}');
    }
  }

  Future<Pet> getPetById(int id) async {
    try {
      final response = await _dio.get('/pet/$id');
      return Pet.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Failed to fetch pet: ${e.message}');
    }
  }

  Future<Pet> createPet(Pet pet) async {
    try {
      final response = await _dio.post(
        '/pet',
        data: pet.toJson(),
      );
      return Pet.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create pet: ${e.message}');
    }
  }

  Future<Pet> updatePet(Pet pet) async {
    try {
      final response = await _dio.put(
        '/pet',
        data: pet.toJson(),
      );
      return Pet.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Failed to update pet: ${e.message}');
    }
  }

  Future<void> deletePet(int id) async {
    try {
      await _dio.delete('/pet/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pet not found');
      }
      throw Exception('Failed to delete pet: ${e.message}');
    }
  }
}