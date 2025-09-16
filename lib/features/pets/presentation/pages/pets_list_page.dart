import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pets_list_controller.dart';
import '../../data/pet_models.dart';
import '../widgets/new_pet_dialog.dart';

class PetsListPage extends ConsumerWidget {
  const PetsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsListState = ref.watch(petsListControllerProvider);
    final petsListController = ref.read(petsListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pets'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: petsListController.currentStatus,
              underline: Container(),
              dropdownColor: Theme.of(context).appBarTheme.backgroundColor,
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              items: const [
                DropdownMenuItem(value: 'available', child: Text('Available')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'sold', child: Text('Sold')),
              ],
              onChanged: (status) {
                if (status != null) {
                  petsListController.setStatus(status);
                }
              },
            ),
          ),
        ],
      ),
      body: petsListState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading pets',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => petsListController.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (pets) => pets.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No pets found'),
                  ],
                ),
              )
            : _PetsGrid(pets: pets),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPetDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewPetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => NewPetDialog(
        onPetCreated: () {
          ref.read(petsListControllerProvider.notifier).refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet created successfully!')),
          );
        },
      ),
    );
  }
}

class _PetsGrid extends StatelessWidget {
  final List<Pet> pets;

  const _PetsGrid({required this.pets});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return _PetCard(pet: pet);
          },
        );
      },
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;

  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (pet.id != null) {
            context.go('/pets/${pet.id}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Hero(tag: 'pet-image-${pet.id}', child: _buildPetImage()),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(pet.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pet.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage() {
    if (pet.photoUrls.isNotEmpty) {
      return Image.network(
        pet.photoUrls.first,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.pets, size: 48, color: Colors.grey),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'sold':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
