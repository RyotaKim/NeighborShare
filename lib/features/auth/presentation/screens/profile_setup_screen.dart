import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/username_field.dart';

/// Profile setup screen after email verification
/// Collects username, full name (optional), and neighborhood
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _bioController = TextEditingController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _avatarUrl;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _neighborhoodController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate current step
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentStep == 0) {
      // Move to step 2 (neighborhood selection)
      setState(() {
        _currentStep = 1;
      });
    } else {
      // Complete profile setup
      await _handleFinishSetup();
    }
  }

  Future<void> _handleFinishSetup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authNotifierProvider.notifier).updateProfile(
            username: _usernameController.text.trim(),
            fullName: _fullNameController.text.trim().isNotEmpty
                ? _fullNameController.text.trim()
                : null,
            neighborhood: _neighborhoodController.text.trim().isNotEmpty
                ? _neighborhoodController.text.trim()
                : null,
            bio: _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
            avatarUrl: _avatarUrl,
          );

      if (!mounted) return;

      // Navigate to home feed
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      });
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _handlePickAvatar() {
    // TODO: Implement image picker
    // This will be implemented in Phase 7 (Camera Integration)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar picker coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        automaticallyImplyLeading: _currentStep > 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _isLoading ? null : _handleBack,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 2,
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step indicator
                      Text(
                        'Step ${_currentStep + 1} of 2',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      if (_currentStep == 0)
                        _buildStep1(theme)
                      else
                        _buildStep2(theme),

                      const SizedBox(height: 24),

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Continue button
                      CustomButton(
                        text: _currentStep == 0 ? 'Continue' : 'Finish Setup',
                        onPressed: _handleContinue,
                        isLoading: _isLoading,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          'Create Your Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Tell us a bit about yourself',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Avatar picker
        Center(
          child: GestureDetector(
            onTap: _isLoading ? null : _handlePickAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  backgroundImage: _avatarUrl != null
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: _avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Avatar hint
        Text(
          'Tap to add photo (optional)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Username field with availability check
        UsernameField(
          controller: _usernameController,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),

        // Full name field (optional)
        TextFormField(
          controller: _fullNameController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full Name (Optional)',
            prefixIcon: Icon(Icons.person_outline),
          ),
          enabled: !_isLoading,
          onFieldSubmitted: (_) => _handleContinue(),
        ),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          'Where Are You Located?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Connect with neighbors in your area',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Neighborhood field
        TextFormField(
          controller: _neighborhoodController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Neighborhood',
            prefixIcon: Icon(Icons.location_on_outlined),
            helperText: 'e.g., Downtown, Westside, Green Valley',
          ),
          validator: Validators.requiredValidator('Neighborhood'),
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),

        // Bio field (optional)
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          maxLength: 500,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Bio (Optional)',
            prefixIcon: Icon(Icons.info_outline),
            helperText: 'Tell your neighbors about yourself',
            alignLabelWithHint: true,
          ),
          validator: Validators.validateBio,
          enabled: !_isLoading,
          onFieldSubmitted: (_) => _handleContinue(),
        ),
        const SizedBox(height: 16),

        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can update your profile information anytime in settings.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
