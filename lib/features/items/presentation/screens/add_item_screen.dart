import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/items_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/item_image_picker.dart';

/// Screen for adding a new item to the catalog
/// 
/// Features:
/// - Image preview with change option
/// - Title and description fields with validation
/// - Category selection
/// - Form validation
/// - Loading state during upload
/// - Success feedback
class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedImage;
  ItemCategory? _selectedCategory;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Handle image selection from picker
  void _onImageSelected(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  /// Validate and submit the form
  Future<void> _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check image
    if (_selectedImage == null) {
      _showError('Please add a photo of your item');
      return;
    }

    // Check category
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Compress image
      final compressedImage = await ImageUtils.compressImage(_selectedImage!);
      
      // Generate thumbnail
      final thumbnail = await ImageUtils.generateThumbnail(_selectedImage!);

      // Create item through provider
      await ref.read(itemNotifierProvider.notifier).createItem(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            category: _selectedCategory!,
            fullImage: compressedImage,
            thumbnail: thumbnail,
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Item published successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to home
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to publish item: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  /// Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show image picker dialog
  Future<void> _showImagePickerDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Photo'),
        content: ItemImagePicker(
          onImageConfirmed: (image) {
            _onImageSelected(image);
            Navigator.pop(context);
          },
          initialImage: _selectedImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Image preview section
              if (_selectedImage != null)
                Column(
                  children: [
                    // Large image preview
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Change photo button
                    OutlinedButton.icon(
                      onPressed: _showImagePickerDialog,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Change Photo'),
                    ),
                    const SizedBox(height: 24),
                  ],
                )
              else
                Column(
                  children: [
                    // Add photo button
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: _showImagePickerDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 64,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Add Photo',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Take a clear, well-lit photo',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Cordless Drill',
                  helperText: '${_titleController.text.length}/60',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                ),
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                validator: Validators.validateTitle,
                onChanged: (_) => setState(() {}), // Update character count
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Condition, special notes, accessories included...',
                  helperText: '${_descriptionController.text.length}/500',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLength: 500,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}), // Update character count
              ),
              const SizedBox(height: 24),

              // Category selector
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Availability info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your item will be marked as "Available" by default. You can change this later.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              CustomButton(
                text: 'Publish Item',
                onPressed: _isUploading ? null : _submitForm,
                isLoading: _isUploading,
                isFullWidth: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
