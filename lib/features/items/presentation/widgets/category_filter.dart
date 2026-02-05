import 'package:flutter/material.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../shared/theme/colors.dart' as theme_colors;

/// Horizontal scrollable category filter chips
/// 
/// Shows "All" option plus all 4 category options:
/// - Tools 🔧
/// - Kitchen 🍳
/// - Outdoor 🏕️
/// - Games 🎮
/// 
/// Handles filter selection with visual feedback
class CategoryFilter extends StatelessWidget {
  final ItemCategory? selectedCategory;
  final ValueChanged<ItemCategory?> onCategorySelected;
  final Map<ItemCategory, int>? itemCounts;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.itemCounts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          _FilterChip(
            label: 'All',
            icon: '📦',
            isSelected: selectedCategory == null,
            count: itemCounts?.values.fold<int>(0, (sum, count) => sum + count),
            onTap: () => onCategorySelected(null),
          ),
          
          const SizedBox(width: 8),
          
          // Category chips
          ...ItemCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: category.label,
                icon: category.icon,
                isSelected: selectedCategory == category,
                count: itemCounts?[category],
                onTap: () => onCategorySelected(category),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Individual filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get category color if this is a category chip (not "All")
    final categoryColor = _getCategoryColor(label);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (categoryColor ?? colorScheme.primary)
                : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? (categoryColor ?? colorScheme.primary)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Text(
                icon,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.white : null,
                ),
              ),
              
              const SizedBox(width: 6),
              
              // Label
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              
              // Count badge (optional)
              if (count != null && count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Get the color for a specific category
  Color? _getCategoryColor(String label) {
    switch (label) {
      case 'Tools':
        return theme_colors.CategoryColors.tools;
      case 'Kitchen':
        return theme_colors.CategoryColors.kitchen;
      case 'Outdoor':
        return theme_colors.CategoryColors.outdoor;
      case 'Games':
        return theme_colors.CategoryColors.games;
      default:
        return null;
    }
  }
}
