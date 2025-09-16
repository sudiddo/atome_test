import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pet_detail_controller.dart';
import '../../data/pet_models.dart';

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
          onPressed: () => context.go('/'),
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
            return const Center(
              child: Text('Pet not found'),
            );
          }
          return _PetDetailContent(pet: pet);
        },
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