import 'package:flutter/material.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../shared/theme/colors.dart' as theme_colors;

/// Category selector widget with 4 large buttons for item categories
/// 
/// Features:
/// - Visual buttons for each category (Tools, Kitchen, Outdoor, Games)
/// - Icons and labels
/// - Single selection
/// - Visual feedback for selected state
class CategorySelector extends StatelessWidget {
  /// Currently selected category (can be null)
  final ItemCategory? selectedCategory;

  /// Callback when category is selected
  final Function(ItemCategory) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: ItemCategory.values.map((category) {
            return _CategoryButton(
              category: category,
              isSelected: selectedCategory == category,
              onTap: () => onCategorySelected(category),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Individual category button
class _CategoryButton extends StatelessWidget {
  final ItemCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = theme_colors.CategoryColors.getColor(category);

    return Material(
      color: isSelected
          ? categoryColor.withOpacity(0.15)
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? categoryColor : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category icon (emoji)
              Text(
                category.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              // Category label
              Text(
                category.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected ? categoryColor : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  color: categoryColor,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact category selector for smaller spaces (e.g., filters)
class CompactCategorySelector extends StatelessWidget {
  final ItemCategory? selectedCategory;
  final Function(ItemCategory) onCategorySelected;

  const CompactCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ItemCategory.values.map((category) {
        final isSelected = selectedCategory == category;
        final categoryColor = theme_colors.CategoryColors.getColor(category);

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category.icon),
              const SizedBox(width: 4),
              Text(category.label),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onCategorySelected(category);
            }
          },
          selectedColor: categoryColor.withOpacity(0.2),
          checkmarkColor: categoryColor,
          side: BorderSide(
            color: isSelected ? categoryColor : theme.colorScheme.outline.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }
}
