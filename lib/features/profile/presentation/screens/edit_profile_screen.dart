import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _bioController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final profileAsync = ref.read(currentProfileProvider);
    final profile = profileAsync.value;

    if (profile != null) {
      _fullNameController.text = profile.fullName ?? '';
      _neighborhoodController.text = profile.neighborhood ?? '';
      _bioController.text = profile.bio ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _neighborhoodController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.session?.user.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: Text('Not authenticated')),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          return await _showDiscardDialog(context);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SmallLoadingIndicator()
                  : const Text('Save'),
            ),
          ],
        ),
        body: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Profile not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                onChanged: () => setState(() => _hasChanges = true),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Section
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : (profile.hasAvatar 
                                          ? NetworkImage(profile.avatarUrl!) 
                                          : null) as ImageProvider?,
                                  child: (profile.hasAvatar || _selectedImage != null)
                                      ? null
                                      : Text(
                                          profile.username[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.edit),
                            label: const Text('Change Photo'),
                          ),
                          if (profile.hasAvatar || _selectedImage != null)
                            TextButton.icon(
                              onPressed: () => _removeAvatar(profile),
                              icon: const Icon(Icons.delete),
                              label: const Text('Remove Photo'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Username (read-only)
                    Text(
                      'Username',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '@${profile.username}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Username cannot be changed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),

                    const SizedBox(height: 16),

                    // Neighborhood
                    TextFormField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(
                        labelText: 'Neighborhood',
                        hintText: 'e.g., Downtown, Uptown',
                        border: OutlineInputBorder(),
                        helperText: 'Your community area',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Neighborhood is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Bio
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        labelText: 'Bio (Optional)',
                        hintText: 'Tell others about yourself...',
                        border: const OutlineInputBorder(),
                        helperText: 'Maximum ${AppConstants.maxBioLength} characters',
                        counterText: '${_bioController.text.length}/${AppConstants.maxBioLength}',
                      ),
                      maxLines: 4,
                      maxLength: AppConstants.maxBioLength,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
          loading: () => const LoadingIndicator(message: 'Loading profile...'),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load profile'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(currentProfileProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _hasChanges = true;
      });
    }
  }

  Future<void> _removeAvatar(dynamic profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Photo'),
        content: const Text('Are you sure you want to remove your profile photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _selectedImage = null;
      _hasChanges = true;
    });

    // If there's an existing avatar, delete it
    if (profile.hasAvatar) {
      final authState = ref.read(authStateProvider);
      final userId = authState.value?.session?.user.id;
      if (userId != null) {
        try {
          await ref.read(profileNotifierProvider(userId).notifier).deleteAvatar(profile.avatarUrl);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photo removed')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to remove photo: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authStateProvider);
    final userId = authState.value?.session?.user.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Upload avatar if changed
      if (_selectedImage != null) {
        await ref.read(profileNotifierProvider(userId).notifier).uploadAvatar(_selectedImage!);
      }

      // Update profile fields
      final updates = {
        'full_name': _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        'neighborhood': _neighborhoodController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      };

      await ref.read(profileNotifierProvider(userId).notifier).updateProfile(updates);

      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  Future<bool> _showDiscardDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
