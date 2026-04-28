class User {
  final int id;
  final String nombre;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class TokenResponse {
  final String accessToken;
  final String tokenType;

  const TokenResponse({required this.accessToken, required this.tokenType});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}

class UserResponse {
  final User user;

  const UserResponse({required this.user});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('user')) {
      return UserResponse(
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
    }

    return UserResponse(user: User.fromJson(json));
  }
}
