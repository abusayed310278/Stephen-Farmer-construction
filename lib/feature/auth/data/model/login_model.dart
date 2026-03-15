class LoginRequest {
  final String email;
  final String password;
  final String category;

  LoginRequest({
    required this.email,
    required this.password,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    "email": email.trim(),
    "password": password,
    "category": category,
  };
}

class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({required this.success, required this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json["success"] == true,
      message: (json["message"] ?? "").toString(),
      data: json["data"] != null ? LoginData.fromJson(json["data"]) : null,
    );
  }
}

class LoginData {
  final String accessToken;
  final String refreshToken;
  final String name;
  final String email;
  final String role;
  final String id;
  final String category;
  final String? avatar;

  LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.name,
    required this.email,
    required this.role,
    required this.id,
    required this.category,
    this.avatar,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    final avatar = _extractMediaUrl(
      json["avatar"] ?? json["photoUrl"] ?? json["imageUrl"],
    );
    return LoginData(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      name: json["name"],
      email: json["email"],
      role: json["role"],
      id: json["_id"],
      category: json["category"],
      avatar: avatar.isEmpty ? null : avatar,
    );
  }
}

class UserProfileData {
  final String id;
  final String name;
  final String email;
  final String role;
  final String category;
  final String? avatar;

  const UserProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.category,
    this.avatar,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    final nested = json['user'];
    final source = nested is Map<String, dynamic> ? nested : json;

    String read(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = source[key];
        final resolved = _extractMediaUrl(value);
        if (resolved.isNotEmpty) {
          return resolved;
        }
      }
      return fallback;
    }

    final avatar = _extractMediaUrl(
      source['avatar'] ?? source['photoUrl'] ?? source['imageUrl'],
    );

    return UserProfileData(
      id: read(['_id', 'id', 'userId']),
      name: read(['name', 'fullName'], fallback: 'User'),
      email: read(['email']),
      role: read(['role']),
      category: read(['category']),
      avatar: avatar.isEmpty ? null : avatar,
    );
  }
}

String _extractMediaUrl(dynamic raw) {
  if (raw == null) return '';

  if (raw is String) {
    final value = raw.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';

    if (value.startsWith('{') && value.contains('url:')) {
      final match = RegExp(r'url:\s*([^,}]+)').firstMatch(value);
      final extracted = match?.group(1)?.trim() ?? '';
      return extracted;
    }
    return value;
  }

  if (raw is Map) {
    const keys = <String>[
      'url',
      'secure_url',
      'secureUrl',
      'imageUrl',
      'image_url',
      'avatar',
      'path',
      'src',
    ];
    for (final key in keys) {
      final value = _extractMediaUrl(raw[key]);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  if (raw is List) {
    for (final item in raw) {
      final value = _extractMediaUrl(item);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  return '';
}
