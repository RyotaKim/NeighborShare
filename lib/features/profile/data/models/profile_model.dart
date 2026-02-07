class ProfileModel {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? neighborhood;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.neighborhood,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      neighborhood: json['neighborhood'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'neighborhood': neighborhood,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to JSON for updates (only updatable fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'neighborhood': neighborhood,
      'bio': bio,
    };
  }

  // CopyWith method
  ProfileModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? neighborhood,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
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

  // Helper getters
  String get displayName => fullName?.isNotEmpty == true ? fullName! : username;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  bool get hasNeighborhood => neighborhood != null && neighborhood!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;

  @override
  String toString() {
    return 'ProfileModel(id: $id, username: $username, fullName: $fullName, neighborhood: $neighborhood)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfileModel &&
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
    return Object.hash(
      id,
      username,
      fullName,
      avatarUrl,
      neighborhood,
      bio,
      createdAt,
      updatedAt,
    );
  }
}
