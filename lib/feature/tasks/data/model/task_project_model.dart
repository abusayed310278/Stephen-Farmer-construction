import '../../domain/entities/task_project_entity.dart';
import '../../../../core/utils/images.dart';

class TaskItemModel extends TaskItemEntity {
  const TaskItemModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.subtitle,
    required super.priority,
    super.phaseStatus,
    super.description,
    super.imageUrls,
    super.chatId,
    super.needsApproval,
    super.status,
    super.approvalStatus,
  });

  factory TaskItemModel.fromJson(Map<String, dynamic> json) {
    final imageUrls = _readImageUrls(json);
    final projectMap = _readMap(json, ['project', 'projectInfo']);
    final projectId = _readString(json, ["projectId", "project_id"]);
    final normalizedStatus = _readString(json, [
      "phaseStatus",
      "status",
      "taskStatus",
    ], fallback: "");
    return TaskItemModel(
      id: _readString(json, ["_id", "id", "taskId"]),
      projectId: projectId.isNotEmpty
          ? projectId
          : _readString(projectMap, ["_id", "id", "projectId"]),
      title: _readString(json, [
        "title",
        "taskTitle",
        "task_title",
        "taskName",
        "task_name",
        "subject",
        "name",
      ], fallback: "Untitled task"),
      subtitle: _readString(json, ["subtitle", "description"], fallback: ""),
      priority: _readString(json, ["priority", "level"], fallback: "Medium"),
      phaseStatus: normalizedStatus,
      description: _readString(json, [
        "description",
        "details",
        "body",
        "subtitle",
      ]),
      imageUrls: imageUrls,
      chatId: _readString(json, ["chatId", "chat"]),
      needsApproval: _readBool(json, ["needsApproval", "requiresApproval"]),
      status: normalizedStatus,
      approvalStatus: _readString(json, ["approvalStatus", "approval_status"]),
    );
  }
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
  }
  return const <String, dynamic>{};
}

class TaskSectionModel extends TaskSectionEntity {
  const TaskSectionModel({
    required super.title,
    required super.pendingCount,
    required super.items,
  });

  factory TaskSectionModel.fromJson(Map<String, dynamic> json) {
    final rows = json["items"];
    final items = rows is List
        ? rows
              .whereType<Map<String, dynamic>>()
              .map(TaskItemModel.fromJson)
              .toList()
        : <TaskItemModel>[];
    final explicitPending = _readOptionalInt(json, ["pendingCount", "pending"]);
    final derivedPending = items.where((item) => !item.isFinished).length;

    return TaskSectionModel(
      title: _readString(json, ["title", "name"], fallback: "Your Actions"),
      pendingCount: explicitPending ?? derivedPending,
      items: items,
    );
  }
}

class TaskProjectModel extends TaskProjectEntity {
  const TaskProjectModel({
    required super.id,
    required super.projectName,
    required super.projectAddress,
    super.thumbnailUrl,
    required super.actionsNeededCount,
    required super.actionsNeededMessage,
    required super.sections,
  });

  factory TaskProjectModel.fromJson(Map<String, dynamic> json) {
    final project = json["project"] is Map<String, dynamic>
        ? json["project"] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rows = json["sections"] ?? json["taskSections"] ?? json["groups"];
    final sections = rows is List
        ? rows
              .whereType<Map<String, dynamic>>()
              .map(TaskSectionModel.fromJson)
              .toList()
        : <TaskSectionModel>[];
    final explicitActionsCount = _readOptionalInt(json, [
      "actionsNeededCount",
      "actionsCount",
    ]);
    final derivedActionsCount = _deriveActionsNeededCount(sections);
    final resolvedActionsCount = explicitActionsCount ?? derivedActionsCount;
    final fallbackMessage = resolvedActionsCount > 0
        ? "Your decisions are required to keep progress on track"
        : "No actions needed right now";

    final imageFromCollection = _extractString(
      json["images"] ?? json["photos"] ?? json["attachments"],
    );
    final projectImageFromCollection = _extractString(
      project["images"] ?? project["photos"] ?? project["attachments"],
    );
    final genericImage = imageFromCollection.isNotEmpty
        ? imageFromCollection
        : projectImageFromCollection;

    final thumbnailUrl = _readString(
      json,
      [
        "thumbnailUrl",
        "thumbnail",
        "thumb",
        "imageUrl",
        "image",
        "coverImage",
        "projectImage",
      ],
      fallback: _readString(project, [
        "thumbnailUrl",
        "thumbnail",
        "thumb",
        "imageUrl",
        "image",
        "coverImage",
        "projectImage",
      ], fallback: genericImage),
    );

    return TaskProjectModel(
      id: _readString(json, ["_id", "id", "projectId"]),
      projectName: _readString(
        json,
        ["projectName", "name", "title"],
        fallback: _readString(project, [
          "projectName",
          "name",
          "title",
        ], fallback: "Untitled Project"),
      ),
      projectAddress: _readString(
        json,
        ["projectAddress", "project_address", "address", "location", "city"],
        fallback: _readString(project, [
          "projectAddress",
          "project_address",
          "address",
          "location",
          "city",
        ], fallback: "N/A"),
      ),
      thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
      actionsNeededCount: resolvedActionsCount,
      actionsNeededMessage: _readString(json, [
        "actionsNeededMessage",
        "actionsMessage",
      ], fallback: fallbackMessage),
      sections: sections,
    );
  }

  static const List<TaskProjectModel> dummyData = [
    TaskProjectModel(
      id: "project-1",
      projectName: "Riverside Apartment Renovation",
      projectAddress: "42 Harbor View Drive, Apt 12B",
      thumbnailUrl: AssetsImages.actionsNeeded,
      actionsNeededCount: 2,
      actionsNeededMessage:
          "Your decisions are required to keep progress on track",
      sections: [
        TaskSectionModel(
          title: "Your Actions",
          pendingCount: 2,
          items: [
            TaskItemModel(
              id: "task-1",
              projectId: "project-1",
              title: "Approve bathroom tile layout",
              subtitle: "Review the update tile...",
              priority: "HIGH",
              phaseStatus: "active",
            ),
            TaskItemModel(
              id: "task-2",
              projectId: "project-1",
              title: "Select Door handles",
              subtitle: "Review the update tile...",
              priority: "Medium",
              phaseStatus: "finished",
            ),
          ],
        ),
        TaskSectionModel(
          title: "Designer Tasks",
          pendingCount: 2,
          items: [
            TaskItemModel(
              id: "task-3",
              projectId: "project-1",
              title: "Finalize furniture layout",
              subtitle: "Complete 3D renders for client...",
              priority: "HIGH",
              phaseStatus: "active",
            ),
            TaskItemModel(
              id: "task-4",
              projectId: "project-1",
              title: "Order window treatments",
              subtitle: "Review the update tile...",
              priority: "Medium",
              phaseStatus: "active",
            ),
          ],
        ),
      ],
    ),

    TaskProjectModel(
      id: "project-2",
      projectName: "Cityline Duplex Build",
      projectAddress: "15 Lakefront Ave, Unit 12",
      thumbnailUrl:
          "https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=400&auto=format&fit=crop",
      actionsNeededCount: 1,
      actionsNeededMessage: "One approval is pending to continue execution.",
      sections: [
        TaskSectionModel(
          title: "Your Actions",
          pendingCount: 1,
          items: [
            TaskItemModel(
              id: "task-5",
              projectId: "project-2",
              title: "Confirm kitchen island material",
              subtitle: "Approve the final finish option...",
              priority: "HIGH",
              phaseStatus: "active",
            ),
          ],
        ),
        TaskSectionModel(
          title: "Designer Tasks",
          pendingCount: 1,
          items: [
            TaskItemModel(
              id: "task-6",
              projectId: "project-2",
              title: "Lighting mockup revisions",
              subtitle: "Update pendant placement render...",
              priority: "Medium",
              phaseStatus: "finished",
            ),
          ],
        ),
      ],
    ),
  ];
}

int _deriveActionsNeededCount(List<TaskSectionModel> sections) {
  if (sections.isEmpty) return 0;

  int fromActionSections = 0;
  bool hasActionSection = false;
  for (final section in sections) {
    final normalized = section.title.trim().toLowerCase();
    if (normalized.contains('your actions')) {
      hasActionSection = true;
      fromActionSections += section.pendingCount;
    }
  }
  if (hasActionSection) return fromActionSections;

  return sections
      .expand((section) => section.items)
      .where((item) => !item.isFinished)
      .length;
}

String _readString(
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
    final city = _extractString(value['city']);
    final state = _extractString(value['state']);
    final country = _extractString(value['country']);
    final localityParts = <String>[
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (country.isNotEmpty) country,
    ];
    if (localityParts.isNotEmpty) {
      return localityParts.join(', ');
    }

    const textKeys = <String>[
      'projectAddress',
      'project_address',
      'address',
      'location',
      'street',
      'line1',
      'line2',
      'name',
      'title',
      'label',
    ];
    for (final key in textKeys) {
      final candidate = _extractString(value[key]);
      if (candidate.isNotEmpty) return candidate;
    }

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

int? _readOptionalInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (!json.containsKey(key)) continue;
    final value = json[key];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

bool _readBool(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
  }
  return fallback;
}

List<String> _readImageUrls(Map<String, dynamic> json) {
  final rows = json['images'] ?? json['photos'] ?? json['attachments'];
  if (rows is! List) return const <String>[];

  final urls = <String>[];
  for (final row in rows) {
    if (row is String && row.trim().isNotEmpty) {
      urls.add(row.trim());
      continue;
    }
    if (row is Map<String, dynamic>) {
      final url = _readString(row, ['url', 'imageUrl', 'src']);
      if (url.isNotEmpty) {
        urls.add(url);
      }
    }
  }
  return urls;
}
