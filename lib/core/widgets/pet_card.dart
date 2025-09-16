import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../features/pets/data/pet_models.dart';

class PetCard extends StatelessWidget {
  final Pet pet;

  const PetCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            if (pet.id != null) {
              context.go('/pets/${pet.id}');
            }
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image section with overlay
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'pet-image-${pet.id}',
                          child: _buildPetImage(),
                        ),
                        // Gradient overlay for better text readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Status badge positioned on image
                        Positioned(
                          top: AppTheme.spacingM,
                          right: AppTheme.spacingM,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM,
                              vertical: AppTheme.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.getStatusColor(pet.status),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              pet.status.toUpperCase(),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content section with asymmetric design
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pet.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (pet.category != null) ...[
                            const SizedBox(height: AppTheme.spacingS),
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingS),
                                Expanded(
                                  child: Text(
                                    pet.category!.name,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Spacer(),
                          // View details hint
                          Row(
                            children: [
                              Text(
                                'View Details',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingXS),
                              const Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: AppTheme.secondaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetImage() {
    if (pet.photoUrls.isNotEmpty) {
      return SizedBox.expand(
        child: Image.network(
          pet.photoUrls.first,
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
      height: double.infinity,
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Icon(
          Icons.pets,
          size: 48,
          color: AppTheme.secondaryColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}