class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final bool isOnline;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.isOnline = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    bool? isOnline,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'isOnline': isOnline,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }
}