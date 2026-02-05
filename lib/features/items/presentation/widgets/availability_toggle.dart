import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../shared/theme/colors.dart' as theme_colors;
import '../../data/models/item_model.dart';
import '../providers/items_provider.dart';

/// Toggle widget for changing item availability status
/// 
/// Displays a switch that allows item owners to toggle between
/// "Available" and "On Loan" statuses with haptic feedback.
/// Shows confirmation dialog when marking as "On Loan".
class AvailabilityToggle extends ConsumerStatefulWidget {
  final ItemModel item;
  final VoidCallback? onStatusChanged;

  const AvailabilityToggle({
    super.key,
    required this.item,
    this.onStatusChanged,
  });

  @override
  ConsumerState<AvailabilityToggle> createState() => _AvailabilityToggleState();
}

class _AvailabilityToggleState extends ConsumerState<AvailabilityToggle> {
  bool _isLoading = false;

  bool get _isAvailable => widget.item.status == ItemStatus.available;

  Future<void> _handleToggle(bool value) async {
    // Haptic feedback
    await HapticFeedback.mediumImpact();

    final newStatus = value ? ItemStatus.available : ItemStatus.onLoan;

    // Show confirmation dialog when marking as "On Loan"
    if (newStatus == ItemStatus.onLoan) {
      final confirmed = await _showConfirmationDialog();
      if (!confirmed) return;
    }

    await _updateStatus(newStatus);
  }

  Future<bool> _showConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as On Loan?'),
        content: const Text(
          'This will mark the item as currently borrowed. '
          'Other users won\'t be able to request it until you mark it as available again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _updateStatus(ItemStatus newStatus) async {
    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(itemNotifierProvider.notifier)
          .updateItemStatus(widget.item.id, newStatus);

      if (!mounted) return;

      if (success) {
        // Haptic feedback on success
        await HapticFeedback.lightImpact();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == ItemStatus.available
                  ? 'Item marked as available'
                  : 'Item marked as on loan',
            ),
            backgroundColor: newStatus == ItemStatus.available
                ? theme_colors.AppColors.success
                : theme_colors.AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );

        // Callback for parent widget to refresh
        widget.onStatusChanged?.call();
      } else {
        _showErrorMessage();
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Failed to update status. Please try again.'),
        backgroundColor: theme_colors.AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isAvailable
              ? theme_colors.AppColors.available.withOpacity(0.3)
              : theme_colors.AppColors.onLoan.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Status indicator dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isAvailable ? theme_colors.AppColors.available : theme_colors.AppColors.onLoan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isAvailable ? theme_colors.AppColors.available : theme_colors.AppColors.onLoan)
                      .withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Available to borrow',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isAvailable ? 'Ready to share' : 'Currently on loan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Switch
          if (_isLoading)
            const SizedBox(
              width: 51, // Match switch width
              height: 31, // Match switch height
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Switch(
              value: _isAvailable,
              onChanged: _handleToggle,
              activeColor: theme_colors.AppColors.available,
              activeTrackColor: theme_colors.AppColors.available.withOpacity(0.5),
              inactiveThumbColor: theme_colors.AppColors.onLoan,
              inactiveTrackColor: theme_colors.AppColors.onLoan.withOpacity(0.5),
            ),
        ],
      ),
    );
  }
}

/// Compact version of the availability toggle for use in item cards
class CompactAvailabilityToggle extends ConsumerStatefulWidget {
  final ItemModel item;
  final VoidCallback? onStatusChanged;

  const CompactAvailabilityToggle({
    super.key,
    required this.item,
    this.onStatusChanged,
  });

  @override
  ConsumerState<CompactAvailabilityToggle> createState() =>
      _CompactAvailabilityToggleState();
}

class _CompactAvailabilityToggleState
    extends ConsumerState<CompactAvailabilityToggle> {
  bool _isLoading = false;

  bool get _isAvailable => widget.item.status == ItemStatus.available;

  Future<void> _handleToggle(bool value) async {
    await HapticFeedback.lightImpact();

    final newStatus = value ? ItemStatus.available : ItemStatus.onLoan;

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(itemNotifierProvider.notifier)
          .updateItemStatus(widget.item.id, newStatus);

      if (!mounted) return;

      if (success) {
        widget.onStatusChanged?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update status'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 40,
        height: 24,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: _isAvailable,
        onChanged: _handleToggle,
        activeColor: theme_colors.AppColors.available,
        inactiveThumbColor: theme_colors.AppColors.onLoan,
      ),
    );
  }
}
