import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/pet_card.dart';
import '../../../../core/theme/app_theme.dart';
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
      body: CustomScrollView(
        slivers: [
          // Big header section
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.05),
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingL,
                      vertical: AppTheme.spacingXL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Pet Store',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          'Find your perfect companion',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.secondaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Filter in app bar when collapsed
            actions: [
              Container(
                margin: const EdgeInsets.only(right: AppTheme.spacingM),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: petsListController.currentStatus,
                  underline: Container(),
                  icon: const Icon(Icons.tune, size: 18),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  items: const [
                    DropdownMenuItem(
                      value: 'available',
                      child: Text('Available'),
                    ),
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
          // Content section as SliverToBoxAdapter
          SliverToBoxAdapter(
            child: AsyncBody<List<Pet>>(
              value: petsListState,
              loadingWidget: Container(
                padding: const EdgeInsets.only(top: 40),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorBuilder: (error) => Container(
                height: 400,
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorColor.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppTheme.errorColor),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    ElevatedButton.icon(
                      onPressed: () => petsListController.refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
              builder: (pets) => pets.isEmpty
                  ? Container(
                      height: 400,
                      padding: const EdgeInsets.all(AppTheme.spacingXL),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets,
                            size: 80,
                            color: AppTheme.secondaryColor.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          Text(
                            'No pets available',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppTheme.secondaryColor),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            'Try changing the filter or add a new pet',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppTheme.secondaryColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : _PetsGrid(pets: pets),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewPetDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
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
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
            ? 3
            : constraints.maxWidth > 500
            ? 2
            : 1;

        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
                child: Row(
                  children: [
                    Text(
                      'Available Pets',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pets.length} pets',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: AppTheme.spacingL,
                  mainAxisSpacing: AppTheme.spacingL,
                ),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return PetCard(pet: pet);
                },
              ),
              const SizedBox(height: AppTheme.spacingXL),
            ],
          ),
        );
      },
    );
  }
}
