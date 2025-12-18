class UserProfile {
  final String name;
  final String email;
  final String description;
  final String? profileImagePath;
  final DateTime lastUpdated;

  const UserProfile({
    required this.name,
    required this.email,
    required this.description,
    this.profileImagePath,
    required this.lastUpdated,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? description,
    String? profileImagePath,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}