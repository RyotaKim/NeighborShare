import '../../../../core/constants/category_constants.dart';

/// Model representing an item that can be borrowed/lent
/// Maps to the 'items' table and 'items_with_owner' view in Supabase
class ItemModel {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final ItemCategory category;
  final ItemStatus status;
  final String imageUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Owner information (from items_with_owner view)
  final String? ownerUsername;
  final String? ownerFullName;
  final String? ownerAvatarUrl;
  final String? ownerNeighborhood;

  const ItemModel({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.category,
    required this.status,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
    this.ownerUsername,
    this.ownerFullName,
    this.ownerAvatarUrl,
    this.ownerNeighborhood,
  });

  /// Create ItemModel from JSON (from database)
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: ItemCategory.fromString(json['category'] as String),
      status: ItemStatus.fromString(json['status'] as String),
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Owner information (optional, from view)
      ownerUsername: json['owner_username'] as String?,
      ownerFullName: json['owner_full_name'] as String?,
      ownerAvatarUrl: json['owner_avatar_url'] as String?,
      ownerNeighborhood: json['owner_neighborhood'] as String?,
    );
  }

  /// Convert ItemModel to JSON (for database updates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'category': category.toDbString(),
      'status': status.toDbString(),
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to JSON for creating new items (excludes id, timestamps)
  Map<String, dynamic> toCreateJson() {
    return {
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'category': category.toDbString(),
      'status': status.toDbString(),
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
    };
  }

  /// Convert to JSON for updates (only modifiable fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'category': category.toDbString(),
      'status': status.toDbString(),
    };
  }

  /// Create a copy with updated fields
  ItemModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    ItemCategory? category,
    ItemStatus? status,
    String? imageUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerUsername,
    String? ownerFullName,
    String? ownerAvatarUrl,
    String? ownerNeighborhood,
  }) {
    return ItemModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      ownerFullName: ownerFullName ?? this.ownerFullName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      ownerNeighborhood: ownerNeighborhood ?? this.ownerNeighborhood,
    );
  }

  // Helper getters

  /// Get owner display name (full name or username)
  String get ownerDisplayName =>
      ownerFullName?.isNotEmpty == true ? ownerFullName! : ownerUsername ?? 'Unknown';

  /// Check if item is available for borrowing
  bool get isAvailable => status == ItemStatus.available;

  /// Check if item is currently on loan
  bool get isOnLoan => status == ItemStatus.onLoan;

  /// Get the best available image (thumbnail or full)
  String get displayImageUrl => thumbnailUrl ?? imageUrl;

  /// Check if item has owner information loaded
  bool get hasOwnerInfo => ownerUsername != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ItemModel{id: $id, title: $title, category: ${category.label}, '
        'status: ${status.label}, ownerId: $ownerId}';
  }
}
