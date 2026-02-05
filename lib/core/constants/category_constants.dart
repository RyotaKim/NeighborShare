/// Item categories and status enums with display labels and icons
/// 
/// Four main item categories for the NeighborShare app:
/// - Tools (🔧): Drills, hammers, ladders, power tools
/// - Kitchen (🍳): Appliances, cookware, specialty items
/// - Outdoor (🏕️): Camping gear, sports equipment, gardening
/// - Games (🎮): Board games, consoles, party games

enum ItemCategory {
  tools('Tools', '🔧'),
  kitchen('Kitchen', '🍳'),
  outdoor('Outdoor', '🏕️'),
  games('Games', '🎮');
  
  const ItemCategory(this.label, this.icon);
  
  final String label;
  final String icon;
  
  /// Convert from string value (e.g., from database)
  static ItemCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'tools':
        return ItemCategory.tools;
      case 'kitchen':
        return ItemCategory.kitchen;
      case 'outdoor':
        return ItemCategory.outdoor;
      case 'games':
        return ItemCategory.games;
      default:
        throw ArgumentError('Invalid category: $value');
    }
  }
  
  /// Get string value for database storage
  String toDbString() {
    return label;
  }
}

/// Item availability status
/// 
/// Two possible states:
/// - Available: Item is ready to be borrowed
/// - On Loan: Item is currently borrowed by someone
enum ItemStatus {
  available('Available'),
  onLoan('On Loan');
  
  const ItemStatus(this.label);
  
  final String label;
  
  /// Convert from string value (e.g., from database)
  static ItemStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'available':
        return ItemStatus.available;
      case 'on loan':
        return ItemStatus.onLoan;
      default:
        throw ArgumentError('Invalid status: $value');
    }
  }
  
  /// Get string value for database storage
  String toDbString() {
    return label;
  }
  
  /// Whether the item is currently available for borrowing
  bool get isAvailable => this == ItemStatus.available;
}

/// Category-specific colors for UI theming
class CategoryColors {
  static const Map<ItemCategory, int> colorValues = {
    ItemCategory.tools: 0xFF2196F3,    // Blue
    ItemCategory.kitchen: 0xFFFF9800,  // Orange
    ItemCategory.outdoor: 0xFF4CAF50,  // Green
    ItemCategory.games: 0xFF9C27B0,    // Purple
  };
}

/// Status indicator colors
class StatusColors {
  static const int available = 0xFF4CAF50;  // Green
  static const int onLoan = 0xFFF44336;     // Red
}
