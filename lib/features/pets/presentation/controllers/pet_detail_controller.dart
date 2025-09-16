import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/pet_models.dart';
import 'pets_list_controller.dart';

class PetDetailController extends AsyncNotifier<Pet?> {
  @override
  Future<Pet?> build() async {
    return null;
  }

  Future<void> load(int id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(petsRepositoryProvider);
      final pet = await repository.getPetById(id);
      state = AsyncValue.data(pet);
    } catch (e) {
      // Handle "Pet not found" and other API errors
      if (e.toString().contains('Pet not found')) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<Pet?> create(Pet pet) async {
    try {
      final repository = ref.read(petsRepositoryProvider);
      final createdPet = await repository.createPet(pet);
      state = AsyncValue.data(createdPet);
      
      // Refresh the pets list to show the new pet
      ref.invalidate(petsListControllerProvider);
      
      return createdPet;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<Pet?> updatePet(Pet pet) async {
    try {
      final repository = ref.read(petsRepositoryProvider);
      final updatedPet = await repository.updatePet(pet);
      state = AsyncValue.data(updatedPet);
      
      // Refresh the pets list to show the updated pet
      ref.invalidate(petsListControllerProvider);
      
      return updatedPet;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      final repository = ref.read(petsRepositoryProvider);
      await repository.deletePet(id);
      state = const AsyncValue.data(null);
      
      // Refresh the pets list to remove the deleted pet
      ref.invalidate(petsListControllerProvider);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final petDetailControllerProvider = AsyncNotifierProvider<PetDetailController, Pet?>(() {
  return PetDetailController();
});