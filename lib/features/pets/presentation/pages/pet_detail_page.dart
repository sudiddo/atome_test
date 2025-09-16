import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/theme/app_theme.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () {
              ref.read(petsListControllerProvider.notifier).refresh();
              context.go('/');
            },
          ),
        ),
        actions: petState.when(
          data: (pet) => pet != null ? [
            Container(
              margin: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditDialog(context, pet),
                    icon: const Icon(Icons.edit, size: 20, color: AppTheme.primaryColor),
                    tooltip: 'Edit Pet',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteDialog(context, pet),
                    icon: const Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                    tooltip: 'Delete Pet',
                  ),
                ],
              ),
            ),
          ] : null,
          loading: () => null,
          error: (_, __) => null,
        ),
      ),
      body: AsyncBody<Pet?>(
        value: petState,
        errorBuilder: (error) => Center(
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
        builder: (pet) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image section with overlay
          Stack(
            children: [
              Hero(
                tag: 'pet-image-${pet.id}',
                child: _buildPetImage(),
              ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Status badge on image
              Positioned(
                bottom: AppTheme.spacingL,
                right: AppTheme.spacingL,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: AppTheme.spacingM,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(pet.status),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    pet.status.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Content section with better layout
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet name with bigger typography
                    Text(
                      pet.name,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Meet your new companion',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                
                    const SizedBox(height: AppTheme.spacingXL),
                    
                    // Info cards section
                    Row(
                      children: [
                        // Category card
                        if (pet.category != null)
                          Expanded(
                            child: _buildInfoCard(
                              context: context,
                              icon: Icons.category,
                              title: 'Category',
                              value: pet.category!.name,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        if (pet.category != null && (pet.tags != null && pet.tags!.isNotEmpty))
                          const SizedBox(width: AppTheme.spacingM),
                        // Tags count card  
                        if (pet.tags != null && pet.tags!.isNotEmpty)
                          Expanded(
                            child: _buildInfoCard(
                              context: context,
                              icon: Icons.label,
                              title: 'Tags',
                              value: '${pet.tags!.length} tags',
                              color: AppTheme.successColor,
                            ),
                          ),
                      ],
                    ),
                    
                    if (pet.tags != null && pet.tags!.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingL),
                      _buildSection(
                        context: context,
                        title: 'Personality Tags',
                        child: Wrap(
                          spacing: AppTheme.spacingM,
                          runSpacing: AppTheme.spacingM,
                          children: pet.tags!.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingL,
                                vertical: AppTheme.spacingM,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor.withValues(alpha: 0.1),
                                    AppTheme.primaryColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: AppTheme.spacingS),
                                  Text(
                                    tag.name,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    
                    // Photo URLs section
                    if (pet.photoUrls.length >= 2) ...[
                      const SizedBox(height: AppTheme.spacingL),
                      _buildSection(
                        context: context,
                        title: 'Additional Photos',
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: pet.photoUrls.length - 1,
                            itemBuilder: (context, index) {
                              final url = pet.photoUrls[index + 1]; // Skip first image (hero)
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: AppTheme.spacingS),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildPlaceholder(size: 100),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        child,
      ],
    );
  }

  Widget _buildPetImage() {
    if (pet.photoUrls.isNotEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          pet.photoUrls.first,
          width: double.infinity,
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

  Widget _buildPlaceholder({double? size}) {
    return Container(
      width: double.infinity,
      height: size ?? 250,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
      ),
      child: Icon(
        Icons.pets,
        size: size != null ? size * 0.4 : 64,
        color: AppTheme.secondaryColor.withValues(alpha: 0.6),
      ),
    );
  }
}