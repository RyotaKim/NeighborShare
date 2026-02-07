import 'package:flutter/material.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../shared/theme/colors.dart' as theme_colors;

/// Horizontal scrollable category filter with circular icons
///
/// Shows circular colored icons with labels below:
/// - Tools 🔧
/// - Kitchen 🍳
/// - Outdoor 🏕️
/// - Games 🎮
///
/// Matches the mockup with large circular icon buttons
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
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ItemCategory.values.map((category) {
          return _CategoryIcon(
            label: category.label,
            icon: category.icon,
            color: theme_colors.CategoryColors.getColor(category),
            lightColor: _getLightColor(category),
            isSelected: selectedCategory == category,
            onTap: () {
              // Toggle: tap again to deselect
              if (selectedCategory == category) {
                onCategorySelected(null);
              } else {
                onCategorySelected(category);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Color _getLightColor(ItemCategory category) {
    switch (category) {
      case ItemCategory.tools:
        return theme_colors.AppColors.toolsCategoryLight;
      case ItemCategory.kitchen:
        return theme_colors.AppColors.kitchenCategoryLight;
      case ItemCategory.outdoor:
        return theme_colors.AppColors.outdoorCategoryLight;
      case ItemCategory.games:
        return theme_colors.AppColors.gamesCategoryLight;
    }
  }
}

/// Circular category icon with label below
class _CategoryIcon extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final Color lightColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryIcon({
    required this.label,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular icon container
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : lightColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Text(
                icon,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Label
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
