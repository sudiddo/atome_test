import 'pets_api.dart';
import 'pet_models.dart';

class PetsRepository {
  final PetsApi _api;

  PetsRepository(this._api);

  Future<List<Pet>> getPetsByStatus(String status) async {
    try {
      return await _api.findPetsByStatus(status);
    } catch (e) {
      throw Exception('Unable to load pets: ${e.toString()}');
    }
  }

  Future<Pet> getPetById(int id) async {
    try {
      return await _api.getPetById(id);
    } catch (e) {
      throw Exception('Unable to load pet: ${e.toString()}');
    }
  }

  Future<Pet> createPet(Pet pet) async {
    try {
      return await _api.createPet(pet);
    } catch (e) {
      throw Exception('Unable to create pet: ${e.toString()}');
    }
  }

  Future<Pet> updatePet(Pet pet) async {
    try {
      return await _api.updatePet(pet);
    } catch (e) {
      throw Exception('Unable to update pet: ${e.toString()}');
    }
  }

  Future<void> deletePet(int id) async {
    try {
      await _api.deletePet(id);
    } catch (e) {
      throw Exception('Unable to delete pet: ${e.toString()}');
    }
  }
}