import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pet_detail_controller.dart';
import '../../data/pet_models.dart';

class EditPetDialog extends ConsumerStatefulWidget {
  final Pet pet;
  final VoidCallback onPetUpdated;

  const EditPetDialog({
    super.key,
    required this.pet,
    required this.onPetUpdated,
  });

  @override
  ConsumerState<EditPetDialog> createState() => _EditPetDialogState();
}

class _EditPetDialogState extends ConsumerState<EditPetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _photoUrlsController;
  late final TextEditingController _categoryNameController;
  late final TextEditingController _tagsController;
  late String _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _photoUrlsController = TextEditingController(
      text: widget.pet.photoUrls.join(', '),
    );
    _categoryNameController = TextEditingController(
      text: widget.pet.category?.name ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.pet.tags?.map((tag) => tag.name).join(', ') ?? '',
    );
    _selectedStatus = widget.pet.status;
  }

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
      title: const Text('Edit Pet'),
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
          onPressed: _isLoading ? null : _updatePet,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updatePet() async {
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

      // Parse category
      Category? category;
      final categoryName = _categoryNameController.text.trim();
      if (categoryName.isNotEmpty) {
        category = Category(
          id: widget.pet.category?.id, // Keep existing ID if available
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
        
        tags = tagNames.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          return Tag(
            id: widget.pet.tags != null && index < widget.pet.tags!.length
                ? widget.pet.tags![index].id
                : index,
            name: name,
          );
        }).toList();
      }

      final updatedPet = widget.pet.copyWith(
        name: _nameController.text.trim(),
        status: _selectedStatus,
        photoUrls: photoUrls,
        category: category,
        tags: tags,
      );

      final controller = ref.read(petDetailControllerProvider.notifier);
      await controller.updatePet(updatedPet);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onPetUpdated();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update pet: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}