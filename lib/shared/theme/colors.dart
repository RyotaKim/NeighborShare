import 'package:flutter/material.dart';
import '../../core/constants/category_constants.dart';

/// App color palette
/// Material Design 3 color system with custom brand colors
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF6750A4); // Purple
  static const Color primaryVariant = Color(0xFF4F378B);
  static const Color secondary = Color(0xFF625B71); // Purple grey
  static const Color secondaryVariant = Color(0xFF4A4458);

  // Background Colors (Light Theme)
  static const Color backgroundLight = Color(0xFFFFFBFE);
  static const Color surfaceLight = Color(0xFFFFFBFE);
  static const Color surfaceVariantLight = Color(0xFFE7E0EC);

  // Background Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF1C1B1F);
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static const Color surfaceVariantDark = Color(0xFF49454F);

  // Text Colors (Light Theme)
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color onSurfaceVariantLight = Color(0xFF49454F);

  // Text Colors (Dark Theme)
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFB3261E); // Red
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color info = Color(0xFF2196F3); // Blue

  // Item Status Colors
  static const Color available = Color(0xFF4CAF50); // Green - item is available
  static const Color onLoan = Color(0xFFEF5350); // Red - item is on loan
  static const Color unavailable = Color(0xFF9E9E9E); // Grey - item is unavailable

  // Category Colors
  // Tools category
  static const Color toolsCategory = Color(0xFF2196F3); // Blue
  static const Color toolsCategoryLight = Color(0xFFE3F2FD);
  static const Color toolsCategoryDark = Color(0xFF1565C0);

  // Kitchen category
  static const Color kitchenCategory = Color(0xFFFF9800); // Orange
  static const Color kitchenCategoryLight = Color(0xFFFFF3E0);
  static const Color kitchenCategoryDark = Color(0xFFE65100);

  // Outdoor category
  static const Color outdoorCategory = Color(0xFF4CAF50); // Green
  static const Color outdoorCategoryLight = Color(0xFFE8F5E9);
  static const Color outdoorCategoryDark = Color(0xFF2E7D32);

  // Games category
  static const Color gamesCategory = Color(0xFF9C27B0); // Purple
  static const Color gamesCategoryLight = Color(0xFFF3E5F5);
  static const Color gamesCategoryDark = Color(0xFF6A1B9A);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  static const Color overlayDark = Color(0xB3000000); // 70% black

  // Divider Colors
  static const Color dividerLight = Color(0x1F000000); // 12% black
  static const Color dividerDark = Color(0x1FFFFFFF); // 12% white

  // Shadow Colors
  static const Color shadowLight = Color(0x33000000); // 20% black
  static const Color shadowDark = Color(0x66000000); // 40% black

  // Badge Colors
  static const Color badgeBackground = Color(0xFFE53935); // Red for notifications
  static const Color badgeText = Color(0xFFFFFFFF);

  // Shimmer Colors (for loading skeletons)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF424242);
  static const Color shimmerHighlightDark = Color(0xFF616161);
}

/// Helper class to get colors by item status
class StatusColors {
  static Color getColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.available:
        return AppColors.available;
      case ItemStatus.onLoan:
        return AppColors.onLoan;
    }
  }

  static Color getStatusBackgroundColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.available.withOpacity(0.1);
      case 'on_loan':
        return AppColors.onLoan.withOpacity(0.1);
      default:
        return AppColors.unavailable.withOpacity(0.1);
    }
  }
}

/// Helper class to get colors by item category
class CategoryColors {
  // Static color getters for direct access
  static const Color tools = AppColors.toolsCategory;
  static const Color kitchen = AppColors.kitchenCategory;
  static const Color outdoor = AppColors.outdoorCategory;
  static const Color games = AppColors.gamesCategory;
  
  static Color getColor(ItemCategory category) {
    switch (category) {
      case ItemCategory.tools:
        return AppColors.toolsCategory;
      case ItemCategory.kitchen:
        return AppColors.kitchenCategory;
      case ItemCategory.outdoor:
        return AppColors.outdoorCategory;
      case ItemCategory.games:
        return AppColors.gamesCategory;
    }
  }
  
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tools':
        return AppColors.toolsCategory;
      case 'kitchen':
        return AppColors.kitchenCategory;
      case 'outdoor':
        return AppColors.outdoorCategory;
      case 'games':
        return AppColors.gamesCategory;
      default:
        return AppColors.grey500;
    }
  }

  static Color getCategoryLightColor(String category) {
    switch (category.toLowerCase()) {
      case 'tools':
        return AppColors.toolsCategoryLight;
      case 'kitchen':
        return AppColors.kitchenCategoryLight;
      case 'outdoor':
        return AppColors.outdoorCategoryLight;
      case 'games':
        return AppColors.gamesCategoryLight;
      default:
        return AppColors.grey100;
    }
  }

  static Color getCategoryDarkColor(String category) {
    switch (category.toLowerCase()) {
      case 'tools':
        return AppColors.toolsCategoryDark;
      case 'kitchen':
        return AppColors.kitchenCategoryDark;
      case 'outdoor':
        return AppColors.outdoorCategoryDark;
      case 'games':
        return AppColors.gamesCategoryDark;
      default:
        return AppColors.grey700;
    }
  }
}

