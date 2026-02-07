import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Username text field with real-time availability check
/// Shows checkmark when username is available, X when taken
class UsernameField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final bool enabled;

  const UsernameField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  @override
  ConsumerState<UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends ConsumerState<UsernameField> {
  Timer? _debounce;
  bool _isChecking = false;
  bool? _isAvailable;
  String? _lastCheckedUsername;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUsernameChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged() {
    final username = widget.controller.text.trim();

    // Cancel previous timer
    _debounce?.cancel();

    // Reset state if username is empty or invalid
    if (username.isEmpty || username.length < 3) {
      setState(() {
        _isChecking = false;
        _isAvailable = null;
        _lastCheckedUsername = null;
      });
      return;
    }

    // Don't check if already checked this username
    if (username == _lastCheckedUsername) {
      return;
    }

    // Show checking state immediately
    setState(() {
      _isChecking = true;
      _isAvailable = null;
    });

    // Debounce the availability check (500ms)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkAvailability(username);
    });
  }

  Future<void> _checkAvailability(String username) async {
    try {
      final isAvailable = await ref.read(
        usernameAvailabilityProvider(username).future,
      );

      if (!mounted) return;

      setState(() {
        _isChecking = false;
        _isAvailable = isAvailable;
        _lastCheckedUsername = username;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isChecking = false;
        _isAvailable = null;
      });
    }
  }

  Widget? _buildSuffixIcon(ThemeData theme) {
    if (_isChecking) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_isAvailable == true) {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    }

    if (_isAvailable == false) {
      return Icon(
        Icons.cancel,
        color: theme.colorScheme.error,
      );
    }

    return null;
  }

  String? _validator(String? value) {
    // First validate format
    final formatError = Validators.validateUsername(value);
    if (formatError != null) {
      return formatError;
    }

    // Then check availability
    if (_isAvailable == false) {
      return 'Username is already taken';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: const Icon(Icons.alternate_email),
        suffixIcon: _buildSuffixIcon(theme),
        helperText: _isAvailable == true
            ? 'Username is available'
            : '3-20 characters, letters, numbers, underscore',
        helperStyle: _isAvailable == true
            ? theme.textTheme.bodySmall?.copyWith(color: Colors.green)
            : null,
      ),
      validator: _validator,
      enabled: widget.enabled,
    );
  }
}
