class UpdateProjectModel {
  final String id;
  final String name;
  final String address;
  final String? thumbnailUrl;

  const UpdateProjectModel({
    required this.id,
    required this.name,
    required this.address,
    this.thumbnailUrl,
  });

  factory UpdateProjectModel.fromJson(Map<String, dynamic> json) {
    String readFirst(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = _extractString(json[key]);
        if (value.isNotEmpty) {
          return value;
        }
      }
      return fallback;
    }

    final thumbFromFields = readFirst([
      'thumbnailUrl',
      'thumbnail',
      'thumb',
      'coverImage',
      'image',
      'imageUrl',
      'projectImage',
    ]);
    final thumbFromImages = _extractString(
      json['images'] ?? json['photos'] ?? json['attachments'],
    );
    final thumb = thumbFromFields.isNotEmpty
        ? thumbFromFields
        : thumbFromImages;

    return UpdateProjectModel(
      id: readFirst(['_id', 'id', 'projectId']),
      name: readFirst(['projectName', 'name', 'title'], fallback: 'Project'),
      address: readFirst(['address', 'location', 'projectAddress']),
      thumbnailUrl: thumb.isEmpty ? null : thumb,
    );
  }
}

class UpdateCommentModel {
  final String id;
  final String updateId;
  final String text;
  final String userName;
  final String? userAvatar;
  final DateTime createdAt;

  const UpdateCommentModel({
    required this.id,
    required this.updateId,
    required this.text,
    required this.userName,
    this.userAvatar,
    required this.createdAt,
  });

  UpdateCommentModel copyWith({
    String? id,
    String? updateId,
    String? text,
    String? userName,
    String? userAvatar,
    DateTime? createdAt,
  }) {
    return UpdateCommentModel(
      id: id ?? this.id,
      updateId: updateId ?? this.updateId,
      text: text ?? this.text,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UpdateCommentModel.fromJson(Map<String, dynamic> json) {
    String readFirst(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return fallback;
    }

    final userRaw = json['user'] ?? json['commentedBy'] ?? json['author'];
    final user = userRaw is Map<String, dynamic>
        ? userRaw
        : <String, dynamic>{};
    final avatar = _readAvatarUrl(user['avatar'] ?? user['photoUrl']);
    final userName = _readName(user, fallback: '');

    return UpdateCommentModel(
      id: readFirst(['_id', 'id', 'commentId']),
      updateId: readFirst(['update', 'updateId', 'update']),
      text: readFirst(['comment', 'text', 'content', 'body']),
      userName: userName.isEmpty ? 'User' : userName,
      userAvatar: avatar.isEmpty ? null : avatar,
      createdAt: _parseDateTime(
        json['createdAt'] ?? json['date'] ?? json['updatedAt'],
      ),
    );
  }
}

String _readName(Map<String, dynamic> user, {String fallback = 'User'}) {
  final candidate = (user['name'] ?? user['fullName'] ?? user['username'] ?? '')
      .toString()
      .trim();
  return candidate.isEmpty ? fallback : candidate;
}

String _readAvatarUrl(dynamic avatarRaw) {
  if (avatarRaw == null) return '';
  if (avatarRaw is String) {
    final value = avatarRaw.trim();
    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return value;
    }
    return '';
  }
  if (avatarRaw is Map<String, dynamic>) {
    final nested =
        (avatarRaw['url'] ?? avatarRaw['secure_url'] ?? avatarRaw['src'] ?? '')
            .toString()
            .trim();
    final lower = nested.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return nested;
    }
  }
  return '';
}

class UpdateModel {
  final String id;
  final String projectId;
  final String category;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final List<String> imageUrls;
  final String authorName;
  final String? authorAvatar;
  final String authorRole;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;

  const UpdateModel({
    required this.id,
    required this.projectId,
    required this.category,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.imageUrls,
    required this.authorName,
    this.authorAvatar,
    required this.authorRole,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLiked,
  });

  UpdateModel copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
  }) {
    return UpdateModel(
      id: id,
      projectId: projectId,
      category: category,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      imageUrls: imageUrls,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorRole: authorRole,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory UpdateModel.fromJson(Map<String, dynamic> json) {
    String readFirst(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return fallback;
    }

    final statsRaw = json['stats'];
    final stats = statsRaw is Map<String, dynamic>
        ? statsRaw
        : <String, dynamic>{};

    final uploadedByRaw = json['uploadedBy'] ?? json['user'] ?? json['author'];
    final uploadedBy = uploadedByRaw is Map<String, dynamic>
        ? uploadedByRaw
        : <String, dynamic>{};

    final imagesRaw = json['images'];
    final imageUrls = <String>[];
    if (imagesRaw is List) {
      for (final image in imagesRaw) {
        if (image is Map<String, dynamic>) {
          final url = (image['url'] ?? image['imageUrl'] ?? '')
              .toString()
              .trim();
          if (url.isNotEmpty) {
            imageUrls.add(url);
          }
        } else {
          final url = image.toString().trim();
          if (url.isNotEmpty) {
            imageUrls.add(url);
          }
        }
      }
    }

    final likesRaw = json['likes'];
    final likesCountFromList = likesRaw is List ? likesRaw.length : 0;

    final title = readFirst([
      'title',
      'headline',
      'name',
      'projectName',
    ], fallback: readFirst(['description'], fallback: 'Site Update'));

    final roleText = (uploadedBy['role'] ?? 'Site Manager').toString().trim();

    return UpdateModel(
      id: readFirst(['_id', 'id', 'updateId']),
      projectId: readFirst(['project', 'projectId']),
      category: readFirst([
        'category',
        'projectCategory',
        'type',
      ], fallback: roleText),
      title: title,
      description: readFirst(['description', 'content', 'body']),
      thumbnailUrl: imageUrls.isEmpty ? null : imageUrls.first,
      imageUrls: imageUrls,
      authorName:
          (uploadedBy['name'] ?? uploadedBy['fullName'] ?? 'Site Manager')
              .toString(),
      authorAvatar:
          _extractString(
            uploadedBy['avatar'] ??
                uploadedBy['photoUrl'] ??
                uploadedBy['imageUrl'] ??
                uploadedBy['image'],
          ).isEmpty
          ? null
          : _extractString(
              uploadedBy['avatar'] ??
                  uploadedBy['photoUrl'] ??
                  uploadedBy['imageUrl'] ??
                  uploadedBy['image'],
            ),
      authorRole: roleText,
      createdAt: _parseDateTime(json['createdAt'] ?? json['updatedAt']),
      likeCount: _asInt(stats['likeCount']) ?? likesCountFromList,
      commentCount: _asInt(stats['commentCount']) ?? 0,
      shareCount: _asInt(stats['shareCount']) ?? 0,
      isLiked: false,
    );
  }

  static List<UpdateModel> dummyData = [
    UpdateModel(
      id: 'demo-1',
      projectId: 'project-1',
      category: 'Foundation',
      title: 'Concrete Work Completed',
      description:
          'The foundation concrete has been successfully poured and cured. Ready for framing phase starting Monday.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=900&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=900&auto=format&fit=crop',
      ],
      authorName: 'Site Manager',
      authorRole: 'manager',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 3,
      commentCount: 3,
      shareCount: 2,
      isLiked: false,
    ),
  ];
}

DateTime _parseDateTime(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed != null) return parsed.toLocal();
  }
  return DateTime.now();
}

String _extractString(dynamic value) {
  if (value == null) return '';

  if (value is String) {
    final trimmed = value.trim();
    return trimmed.toLowerCase() == 'null' ? '' : trimmed;
  }

  if (value is num || value is bool) {
    return value.toString();
  }

  if (value is Map) {
    const keys = <String>[
      'url',
      'imageUrl',
      'image_url',
      'secureUrl',
      'secure_url',
      'src',
      'path',
      'location',
    ];
    for (final key in keys) {
      final nested = _extractString(value[key]);
      if (nested.isNotEmpty) return nested;
    }
    return '';
  }

  if (value is List) {
    for (final item in value) {
      final nested = _extractString(item);
      if (nested.isNotEmpty) return nested;
    }
    return '';
  }

  return '';
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value.trim());
  return null;
}
