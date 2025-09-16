import 'dart:math';
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
  final _categoryNameController = TextEditingController();
  final _tagsController = TextEditingController();
  String _selectedStatus = 'available';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlsController.dispose();
    _categoryNameController.dispose();
    _tagsController.dispose();
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
                style: Theme.of(context).textTheme.bodyMedium,
                items: [
                  DropdownMenuItem(
                    value: 'available',
                    child: Text(
                      'Available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text(
                      'Pending',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'sold',
                    child: Text(
                      'Sold',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
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
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Dogs, Cats, Birds',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., friendly, trained, vaccinated',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _photoUrlsController,
                decoration: const InputDecoration(
                  labelText: 'Photo URLs (comma-separated)',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/photo1.jpg, https://example.com/photo2.jpg',
                  helperText: 'Leave empty to use placeholder image',
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
      // Parse photo URLs - ensure at least one URL exists
      final photoUrlsInput = _photoUrlsController.text.trim();
      final photoUrls = photoUrlsInput.isNotEmpty
          ? photoUrlsInput
              .split(',')
              .map((url) => url.trim())
              .where((url) => url.isNotEmpty)
              .toList()
          : ['https://via.placeholder.com/300']; // Default placeholder if no URLs provided

      // Parse category
      Category? category;
      final categoryName = _categoryNameController.text.trim();
      if (categoryName.isNotEmpty) {
        final random = Random();
        category = Category(
          id: random.nextInt(10000), // Random category ID
          name: categoryName,
        );
      }

      // Parse tags
      List<Tag>? tags;
      final tagsText = _tagsController.text.trim();
      if (tagsText.isNotEmpty) {
        final tagNames = tagsText
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
        
        final random = Random();
        tags = tagNames.map((name) => Tag(
          id: random.nextInt(10000), // Random tag ID
          name: name,
        )).toList();
      }

      final random = Random();
      final pet = Pet(
        id: random.nextInt(100000), // Random pet ID
        name: _nameController.text.trim(),
        status: _selectedStatus,
        photoUrls: photoUrls,
        category: category,
        tags: tags,
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