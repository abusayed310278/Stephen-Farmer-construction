import '../../domain/entities/progress_entity.dart';

class ProgressTaskModel extends ProgressTaskEntity {
  const ProgressTaskModel({
    required super.title,
    required super.status,
    required super.progressPercent,
    super.dateLabel,
  });

  factory ProgressTaskModel.fromJson(Map<String, dynamic> json) {
    final date = _readFirstDateLabel(json, [
      "date",
      "createdAt",
      "created_at",
      "updatedAt",
      "updated_at",
      "completedAt",
      "completed_at",
      "startedAt",
      "started_at",
    ], fallback: "");

    return ProgressTaskModel(
      title: _readFirstString(json, [
        "title",
        "name",
        "task",
      ], fallback: "Untitled Task"),
      status: _readFirstString(json, [
        "status",
        "state",
      ], fallback: "In Progress"),
      progressPercent: _readFirstInt(json, [
        "progressPercent",
        "progress",
        "completion",
      ], fallback: 0),
      dateLabel: date.trim().isEmpty ? null : date,
    );
  }
}

class ProgressUpdateModel extends ProgressUpdateEntity {
  const ProgressUpdateModel({
    required super.id,
    required super.progressName,
    required super.percent,
    required super.note,
    required super.updatedBy,
    super.updatedAtLabel,
  });

  factory ProgressUpdateModel.fromJson(Map<String, dynamic> json) {
    final updatedAt = _readFirstDateLabel(json, [
      "updatedAt",
      "updated_at",
      "createdAt",
      "created_at",
      "date",
    ], fallback: "");

    return ProgressUpdateModel(
      id: _readFirstString(json, ["_id", "id", "progressId"]),
      progressName: _readFirstString(json, [
        "progressName",
        "name",
        "title",
      ], fallback: "Progress Update"),
      percent: _readFirstInt(json, ["percent", "progressPercent", "progress"]),
      note: _readFirstString(json, ["note", "status", "message"], fallback: ""),
      updatedBy: _readFirstString(json, ["updatedBy", "userId", "user"]),
      updatedAtLabel: updatedAt.trim().isEmpty ? null : updatedAt,
    );
  }
}

class ProjectProgressModel extends ProjectProgressEntity {
  const ProjectProgressModel({
    required super.id,
    required super.name,
    required super.address,
    required super.heroImageUrl,
    super.thumbnailUrl,
    required super.overallCompletion,
    required super.dayCurrent,
    required super.dayTotal,
    required super.tasksCompleted,
    required super.tasksTotal,
    required super.photosTotal,
    required super.startedDate,
    required super.handoverDate,
    required super.tasks,
    required super.updates,
  });

  factory ProjectProgressModel.fromJson(Map<String, dynamic> json) {
    final project = json["project"] is Map<String, dynamic>
        ? json["project"] as Map<String, dynamic>
        : const <String, dynamic>{};
    final taskPayload = json["tasks"] ?? json["milestones"] ?? json["items"];
    final taskList = _extractTaskList(taskPayload);
    final updatePayload =
        json["progressUpdates"] ??
        json["progress_updates"] ??
        json["updates"] ??
        json["progress"] ??
        json["progressUpdate"] ??
        json["progress_update"];
    final updates = _extractUpdateList(updatePayload);

    final imageFromCollection = _extractString(
      json["images"] ?? json["photos"] ?? json["attachments"],
    );
    final projectImageFromCollection = _extractString(
      project["images"] ?? project["photos"] ?? project["attachments"],
    );
    final genericImage = imageFromCollection.isNotEmpty
        ? imageFromCollection
        : projectImageFromCollection;

    final heroImageUrl = _readFirstString(
      json,
      ["heroImageUrl", "coverImage", "imageUrl", "image", "projectImage"],
      fallback: _readFirstString(project, [
        "heroImageUrl",
        "coverImage",
        "imageUrl",
        "image",
        "projectImage",
      ], fallback: genericImage),
    );
    final thumbnailUrl = _readFirstString(
      json,
      [
        "thumbnailUrl",
        "thumbnail",
        "thumb",
        "coverImage",
        "imageUrl",
        "image",
        "projectImage",
      ],
      fallback: _readFirstString(project, [
        "thumbnailUrl",
        "thumbnail",
        "thumb",
        "coverImage",
        "imageUrl",
        "image",
        "projectImage",
      ], fallback: genericImage),
    );

    return ProjectProgressModel(
      id: _readFirstString(json, ["_id", "id", "projectId"]),
      name: _readFirstString(json, [
        "name",
        "title",
        "projectName",
      ], fallback: "Untitled Project"),
      address: _readFirstString(json, ["address", "location"], fallback: "N/A"),
      heroImageUrl: heroImageUrl,
      thumbnailUrl: thumbnailUrl.isEmpty
          ? (heroImageUrl.isEmpty ? null : heroImageUrl)
          : thumbnailUrl,
      overallCompletion: _readFirstInt(json, [
        "overallCompletion",
        "progressPercent",
        "completion",
      ], fallback: 0),
      dayCurrent: _readFirstInt(json, [
        "dayCurrent",
        "dayProgress",
        "elapsedDays",
      ], fallback: 0),
      dayTotal: _readFirstInt(json, ["dayTotal", "totalDays"], fallback: 0),
      tasksCompleted: _readFirstInt(json, [
        "tasksCompleted",
        "completedTasks",
      ], fallback: 0),
      tasksTotal: _readFirstInt(json, [
        "tasksTotal",
        "totalTasks",
      ], fallback: 0),
      photosTotal: _readFirstInt(json, [
        "photosTotal",
        "totalPhotos",
      ], fallback: 0),
      startedDate: _readFirstDateLabel(json, [
        "startedDate",
        "startDate",
        "start_date",
        "startedAt",
        "startAt",
        "createdAt",
        "created_at",
      ], fallback: "N/A"),
      handoverDate: _readFirstDateLabel(json, [
        "handoverDate",
        "estHandoverDate",
        "handover_date",
        "est_handover_date",
        "handoverAt",
        "endDate",
        "end_date",
        "deadline",
        "deadlineDate",
      ], fallback: "N/A"),
      tasks: taskList,
      updates: updates,
    );
  }

  static const List<ProjectProgressModel> dummyData = [
    ProjectProgressModel(
      id: 'demo-1',
      name: 'Villa Horizon Renovation',
      address: '42 Harbor View Drive, Apt 12B',
      heroImageUrl:
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=1200&auto=format&fit=crop',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&auto=format&fit=crop',
      overallCompletion: 68,
      dayCurrent: 18,
      dayTotal: 30,
      tasksCompleted: 24,
      tasksTotal: 48,
      photosTotal: 124,
      startedDate: 'Jan 5',
      handoverDate: 'February 5',
      tasks: [
        ProgressTaskModel(
          title: 'Demolition & Strip-out',
          status: 'Completed',
          progressPercent: 100,
        ),
        ProgressTaskModel(
          title: 'Structural Works',
          status: 'In Progress',
          progressPercent: 72,
        ),
        ProgressTaskModel(
          title: 'Electrical Rough-in',
          status: 'In Progress',
          progressPercent: 58,
        ),
        ProgressTaskModel(
          title: 'Plumbing Lines',
          status: 'In Progress',
          progressPercent: 47,
        ),
      ],
      updates: [
        ProgressUpdateModel(
          id: 'demo-u1',
          progressName: 'Foundation Completed',
          percent: 20,
          note: 'Foundation and base slab completed',
          updatedBy: 'system',
          updatedAtLabel: '2026-03-07',
        ),
      ],
    ),
    ProjectProgressModel(
      id: 'demo-2',
      name: 'Riverside Apartment Upgrade',
      address: '15 Lakefront Avenue, Unit 8A',
      heroImageUrl:
          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=1200&auto=format&fit=crop',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1616594039964-3f74d7c6a99c?w=400&auto=format&fit=crop',
      overallCompletion: 52,
      dayCurrent: 14,
      dayTotal: 28,
      tasksCompleted: 19,
      tasksTotal: 40,
      photosTotal: 96,
      startedDate: 'Jan 12',
      handoverDate: 'February 20',
      tasks: [
        ProgressTaskModel(
          title: 'Flooring Demolition',
          status: 'Completed',
          progressPercent: 100,
        ),
        ProgressTaskModel(
          title: 'Wall Framing',
          status: 'In Progress',
          progressPercent: 63,
        ),
        ProgressTaskModel(
          title: 'Ceiling Prep',
          status: 'In Progress',
          progressPercent: 39,
        ),
      ],
      updates: <ProgressUpdateEntity>[],
    ),
  ];
}

List<ProgressTaskModel> _extractTaskList(dynamic payload) {
  if (payload is List) {
    return payload
        .whereType<Map<String, dynamic>>()
        .map(ProgressTaskModel.fromJson)
        .toList();
  }
  return <ProgressTaskModel>[];
}

List<ProgressUpdateModel> _extractUpdateList(dynamic payload) {
  if (payload is List) {
    return payload
        .whereType<Map<String, dynamic>>()
        .map(ProgressUpdateModel.fromJson)
        .toList();
  }
  return <ProgressUpdateModel>[];
}

String _readFirstString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = "",
}) {
  for (final key in keys) {
    final extracted = _extractString(json[key]);
    if (extracted.isNotEmpty) return extracted;
  }
  return fallback;
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
    const imageKeys = <String>[
      'url',
      'imageUrl',
      'image_url',
      'secureUrl',
      'secure_url',
      'src',
      'path',
      'location',
    ];
    for (final key in imageKeys) {
      final candidate = _extractString(value[key]);
      if (candidate.isNotEmpty) return candidate;
    }
    return '';
  }

  if (value is List) {
    for (final item in value) {
      final candidate = _extractString(item);
      if (candidate.isNotEmpty) return candidate;
    }
    return '';
  }

  return '';
}

int _readFirstInt(
  Map<String, dynamic> json,
  List<String> keys, {
  int fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

String _readFirstDateLabel(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = "",
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) return _formatYmd(parsed);
      return trimmed;
    }

    if (value is int) {
      final parsed = _tryParseEpoch(value);
      if (parsed != null) return _formatYmd(parsed);
    }

    if (value is double) {
      final parsed = _tryParseEpoch(value.round());
      if (parsed != null) return _formatYmd(parsed);
    }
  }

  return fallback;
}

DateTime? _tryParseEpoch(int value) {
  // Heuristic: epoch ms is typically 13 digits; epoch seconds ~10 digits.
  if (value <= 0) return null;
  if (value >= 1000000000000) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value >= 1000000000) {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  return null;
}

String _formatYmd(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
}
