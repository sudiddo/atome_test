import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pet_detail_controller.dart';
import '../../data/pet_models.dart';

class NewPetDialog extends ConsumerStatefulWidget {
  final VoidCallback onPetCreated;

  const NewPetDialog({
    super.key,
    required this.onPetCreated,
  });

  @override
  ConsumerState<NewPetDialog> createState() => _NewPetDialogState();
}

class _NewPetDialogState extends ConsumerState<NewPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _photoUrlsController = TextEditingController();
  String _selectedStatus = 'available';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Pet'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Pet name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'available', child: Text('Available')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'sold', child: Text('Sold')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _photoUrlsController,
                decoration: const InputDecoration(
                  labelText: 'Photo URLs (comma-separated)',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/photo1.jpg, https://example.com/photo2.jpg',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createPet,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createPet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final photoUrls = _photoUrlsController.text
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      final pet = Pet(
        name: _nameController.text.trim(),
        status: _selectedStatus,
        photoUrls: photoUrls,
      );

      final controller = ref.read(petDetailControllerProvider.notifier);
      await controller.create(pet);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onPetCreated();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create pet: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}