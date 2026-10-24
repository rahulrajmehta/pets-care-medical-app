/// Domain model representing a user's medical pet-parent profile
class UserProfile {
  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final String role; // 'pet_parent' | 'doctor' | 'admin'
  final bool isProfileCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.avatarUrl,
    this.role = 'pet_parent',
    this.isProfileCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  /// True if user is an administrator
  bool get isAdmin => role == 'admin';

  /// True if user has completed the mandatory first-time profile step
  bool get hasCompletedProfile =>
      isProfileCompleted && fullName.trim().length >= 2;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      // Handle Firestore Timestamp or ISO string
      try {
        if (value.runtimeType.toString() == 'Timestamp' ||
            value.toString().contains('Timestamp(')) {
          // Dynamic reflection for Timestamp without hard-binding class in domain
          final toDate = (value as dynamic).toDate;
          if (toDate is Function) {
            return toDate() as DateTime;
          }
        }
      } catch (_) {}
      return DateTime.tryParse(value.toString());
    }

    return UserProfile(
      id: (json['id'] as String?) ?? '',
      fullName: (json['fullName'] as String?) ??
          (json['full_name'] as String?) ??
          '',
      phone: (json['phone'] as String?),
      email: (json['email'] as String?),
      avatarUrl: (json['avatarUrl'] as String?) ??
          (json['avatar_url'] as String?),
      role: (json['role'] as String?) ?? 'pet_parent',
      isProfileCompleted: (json['isProfileCompleted'] as bool?) ??
          (json['is_profile_completed'] as bool?) ??
          false,
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'role': role,
      'isProfileCompleted': isProfileCompleted,
      'is_profile_completed': isProfileCompleted,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    String? role,
    bool? isProfileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          phone == other.phone &&
          email == other.email &&
          role == other.role &&
          isProfileCompleted == other.isProfileCompleted;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      (phone?.hashCode ?? 0) ^
      (email?.hashCode ?? 0) ^
      role.hashCode ^
      isProfileCompleted.hashCode;
}
