import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/pet_models.dart';
import '../../data/pets_api.dart';
import '../../data/pets_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final petsApiProvider = Provider<PetsApi>((ref) {
  return PetsApi();
});

final petsRepositoryProvider = Provider<PetsRepository>((ref) {
  final api = ref.watch(petsApiProvider);
  return PetsRepository(api);
});

class PetsListController extends AsyncNotifier<List<Pet>> {
  String _currentStatus = 'available';

  String get currentStatus => _currentStatus;

  @override
  Future<List<Pet>> build() async {
    return await _loadPets(_currentStatus);
  }

  Future<List<Pet>> _loadPets(String status) async {
    final repository = ref.read(petsRepositoryProvider);
    return await repository.getPetsByStatus(status);
  }

  Future<void> load({String status = 'available'}) async {
    _currentStatus = status;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadPets(status));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadPets(_currentStatus));
  }

  void setStatus(String status) {
    if (_currentStatus != status) {
      load(status: status);
    }
  }
}

final petsListControllerProvider = AsyncNotifierProvider<PetsListController, List<Pet>>(() {
  return PetsListController();
});