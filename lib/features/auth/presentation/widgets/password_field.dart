import 'package:flutter/material.dart';

/// Password text field widget with show/hide toggle and optional strength indicator
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool showStrengthIndicator;
  final void Function(String)? onFieldSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.textInputAction,
    this.validator,
    this.enabled = true,
    this.showStrengthIndicator = false,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isPasswordVisible = false;
  PasswordStrength _strength = PasswordStrength.none;

  @override
  void initState() {
    super.initState();
    if (widget.showStrengthIndicator) {
      widget.controller.addListener(_updatePasswordStrength);
    }
  }

  @override
  void dispose() {
    if (widget.showStrengthIndicator) {
      widget.controller.removeListener(_updatePasswordStrength);
    }
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _strength = _calculatePasswordStrength(widget.controller.text);
    });
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;

    int score = 0;
    
    // Length
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) score++;
    
    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    
    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) score++;
    
    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: !_isPasswordVisible,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: widget.validator,
          enabled: widget.enabled,
          onFieldSubmitted: widget.onFieldSubmitted,
        ),
        
        // Password strength indicator
        if (widget.showStrengthIndicator && _strength != PasswordStrength.none) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _getStrengthValue(_strength),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  color: _getStrengthColor(_strength, theme),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getStrengthLabel(_strength),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getStrengthColor(_strength, theme),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  double _getStrengthValue(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.none:
        return 0.0;
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  Color _getStrengthColor(PasswordStrength strength, ThemeData theme) {
    switch (strength) {
      case PasswordStrength.none:
        return theme.colorScheme.surfaceVariant;
      case PasswordStrength.weak:
        return theme.colorScheme.error;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  String _getStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
}

/// Password strength enum
enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
}
