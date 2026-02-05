import 'package:flutter/material.dart';
import 'loading_indicator.dart';

/// Custom button widget with loading and disabled states
/// Supports primary and secondary variants
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonVariant variant;
  final IconData? icon;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (variant) {
      case ButtonVariant.primary:
        button = _buildElevatedButton(context);
        break;
      case ButtonVariant.secondary:
        button = _buildOutlinedButton(context);
        break;
      case ButtonVariant.text:
        button = _buildTextButton(context);
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height ?? 48,
        child: button,
      );
    }

    return SizedBox(
      height: height ?? 48,
      child: button,
    );
  }

  Widget _buildElevatedButton(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SmallLoadingIndicator(size: 20, color: Colors.white)
            : Icon(icon),
        label: Text(text),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SmallLoadingIndicator(size: 20, color: Colors.white)
          : Text(text),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SmallLoadingIndicator(
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              )
            : Icon(icon),
        label: Text(text),
      );
    }

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SmallLoadingIndicator(
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            )
          : Text(text),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    if (icon != null) {
      return TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SmallLoadingIndicator(
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              )
            : Icon(icon),
        label: Text(text),
      );
    }

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SmallLoadingIndicator(
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            )
          : Text(text),
    );
  }
}

/// Button variant enum
enum ButtonVariant {
  primary,
  secondary,
  text,
}
