/// User model representing a user profile in the app
/// Maps to the 'profiles' table in Supabase
class UserModel {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? neighborhood;
  final String? bio;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.neighborhood,
    this.bio,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from JSON
  /// Used when fetching data from Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      neighborhood: json['neighborhood'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert UserModel to JSON
  /// Used when sending data to Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'neighborhood': neighborhood,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert UserModel to JSON for updates
  /// Excludes id and created_at since they shouldn't be updated
  Map<String, dynamic> toUpdateJson() {
    return {
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'neighborhood': neighborhood,
      'bio': bio,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? neighborhood,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      neighborhood: neighborhood ?? this.neighborhood,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get user's display name
  /// Returns full name if available, otherwise username
  String get displayName => fullName?.trim().isNotEmpty == true ? fullName! : username;

  /// Check if user has completed profile setup
  /// A complete profile has at least username and neighborhood
  bool get isProfileComplete => username.isNotEmpty && neighborhood?.isNotEmpty == true;

  /// Check if user has avatar
  bool get hasAvatar => avatarUrl?.isNotEmpty == true;

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, fullName: $fullName, neighborhood: $neighborhood)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.fullName == fullName &&
        other.avatarUrl == avatarUrl &&
        other.neighborhood == neighborhood &&
        other.bio == bio &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        fullName.hashCode ^
        avatarUrl.hashCode ^
        neighborhood.hashCode ^
        bio.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
