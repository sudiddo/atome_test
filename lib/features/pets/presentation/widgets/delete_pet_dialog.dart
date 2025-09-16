import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pet_detail_controller.dart';
import '../../data/pet_models.dart';

class DeletePetDialog extends ConsumerStatefulWidget {
  final Pet pet;
  final VoidCallback onPetDeleted;

  const DeletePetDialog({
    super.key,
    required this.pet,
    required this.onPetDeleted,
  });

  @override
  ConsumerState<DeletePetDialog> createState() => _DeletePetDialogState();
}

class _DeletePetDialogState extends ConsumerState<DeletePetDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Pet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delete this pet?'),
          const SizedBox(height: 12),
          Text(
            'Pet: ${widget.pet.name}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This action cannot be undone.',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _deletePet,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _deletePet() async {
    if (widget.pet.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete pet: Invalid pet ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = ref.read(petDetailControllerProvider.notifier);
      await controller.delete(widget.pet.id!);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onPetDeleted();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete pet: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}