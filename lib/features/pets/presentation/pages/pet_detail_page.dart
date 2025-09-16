import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pet_detail_controller.dart';
import '../controllers/pets_list_controller.dart';
import '../../data/pet_models.dart';
import '../widgets/edit_pet_dialog.dart';
import '../widgets/delete_pet_dialog.dart';

class PetDetailPage extends ConsumerStatefulWidget {
  final String petId;

  const PetDetailPage({
    super.key,
    required this.petId,
  });

  @override
  ConsumerState<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends ConsumerState<PetDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = int.tryParse(widget.petId);
      if (id != null) {
        ref.read(petDetailControllerProvider.notifier).load(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petDetailControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Detail - ${widget.petId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(petsListControllerProvider.notifier).refresh();
            context.go('/');
          },
        ),
        actions: petState.when(
          data: (pet) => pet != null ? [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, pet),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, pet),
            ),
          ] : null,
          loading: () => null,
          error: (_, __) => null,
        ),
      ),
      body: petState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading pet',
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
                onPressed: () {
                  final id = int.tryParse(widget.petId);
                  if (id != null) {
                    ref.read(petDetailControllerProvider.notifier).load(id);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (pet) {
          if (pet == null) {
            return _NotFoundContent();
          }
          return _PetDetailContent(pet: pet);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => EditPetDialog(
        pet: pet,
        onPetUpdated: () {
          final id = int.tryParse(widget.petId);
          if (id != null) {
            ref.read(petDetailControllerProvider.notifier).load(id);
          }
          ref.read(petsListControllerProvider.notifier).refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet updated successfully!')),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => DeletePetDialog(
        pet: pet,
        onPetDeleted: () {
          ref.read(petsListControllerProvider.notifier).refresh();
          context.go('/');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet deleted successfully!')),
          );
        },
      ),
    );
  }
}

class _NotFoundContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Pet not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('This pet might have been deleted or the ID is invalid.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(petsListControllerProvider.notifier).refresh();
              context.go('/');
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class _PetDetailContent extends StatelessWidget {
  final Pet pet;

  const _PetDetailContent({required this.pet});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'pet-image-${pet.id}',
            child: _buildPetImage(),
          ),
          const SizedBox(height: 16),
          Text(
            pet.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(pet.status),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              pet.status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (pet.category != null) ...[
            const SizedBox(height: 16),
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(pet.category!.name),
          ],
          if (pet.tags != null && pet.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pet.tags!.map((tag) {
                return Chip(
                  label: Text(tag.name),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
          ],
          if (pet.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Photo URLs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pet.photoUrls.map((url) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    url,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPetImage() {
    if (pet.photoUrls.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          pet.photoUrls.first,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder();
          },
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.pets,
        size: 64,
        color: Colors.grey,
      ),
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