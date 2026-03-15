import 'package:dio/dio.dart';

import '../../../../core/network/api_service/api_client.dart';
import '../../../../core/network/api_service/api_endpoints.dart';
import '../../domain/entities/task_project_entity.dart';
import '../../domain/repository/task_repository.dart';
import '../model/task_project_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required ApiClient apiClient, this.useMockData = false})
    : _apiClient = apiClient;

  final ApiClient _apiClient;
  final bool useMockData;

  @override
  Future<List<TaskProjectEntity>> fetchTaskProjects() async {
    if (useMockData) {
      return TaskProjectModel.dummyData;
    }

    final response = await _apiClient.get(TaskEndpoints.getTasks);
    final rows = _extractList(
      response.data,
      preferredKeys: const ['projects', 'tasks', 'items', 'results', 'data'],
    );

    if (rows.isEmpty) {
      return const <TaskProjectEntity>[];
    }

    final projectImageIndex = await _fetchProjectImageIndex(_apiClient);

    if (_isTaskListPayload(rows)) {
      final built = _buildProjectsFromTaskRows(rows);
      final hydrated = _hydrateMissingThumbnails(built, projectImageIndex);
      return _mergeWithProjectCatalog(hydrated, _latestProjectCatalogRows);
    }

    final built = rows.map(TaskProjectModel.fromJson).toList();
    final hydrated = _hydrateMissingThumbnails(built, projectImageIndex);
    return _mergeWithProjectCatalog(hydrated, _latestProjectCatalogRows);
  }

  @override
  Future<List<TaskItemEntity>> fetchTasks({Map<String, dynamic>? query}) async {
    final response = await _apiClient.get(TaskEndpoints.getTasks, query: query);
    final rows = _extractList(
      response.data,
      preferredKeys: const ['tasks', 'items', 'data'],
    );
    return rows.map(TaskItemModel.fromJson).toList();
  }

  @override
  Future<TaskItemEntity> getTaskDetails(String taskId) async {
    final response = await _apiClient.get(TaskEndpoints.getTaskDetails(taskId));
    return TaskItemModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['task', 'data']),
    );
  }

  @override
  Future<TaskItemEntity> createTask(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      TaskEndpoints.createTask,
      data: payload,
    );
    return TaskItemModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['task', 'data']),
    );
  }

  @override
  Future<TaskItemEntity> updateTaskByManager(
    String taskId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      TaskEndpoints.updateTaskByManager(taskId),
      data: payload,
    );
    return TaskItemModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['task', 'data']),
    );
  }

  @override
  Future<TaskItemEntity> resubmitTaskForApproval(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    final response = await _apiClient.patch(
      TaskEndpoints.resubmitTaskForApproval(taskId),
      data: payload ?? const <String, dynamic>{},
    );
    return TaskItemModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['task', 'data']),
    );
  }

  @override
  Future<TaskItemEntity> approveTask(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    final response = await _apiClient.patch(
      TaskEndpoints.approveTask(taskId),
      data: payload ?? const <String, dynamic>{},
    );
    return TaskItemModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['task', 'data']),
    );
  }

  @override
  Future<TaskItemEntity> rejectTask(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    final response = await _apiClient.patch(
      TaskEndpoints.rejectTask(taskId),
      data: payload ?? const <String, dynamic>{},
    );
    return TaskItemModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['task', 'data']),
    );
  }

  @override
  Future<TaskItemEntity> updateTaskStatus(
    String taskId, {
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.patch(
      TaskEndpoints.updateTaskStatus(taskId),
      data: payload,
    );
    return TaskItemModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['task', 'data']),
    );
  }
}

List<Map<String, dynamic>> _latestProjectCatalogRows =
    const <Map<String, dynamic>>[];

Future<Map<String, String>> _fetchProjectImageIndex(ApiClient apiClient) async {
  try {
    final response = await apiClient.get(ProjectEndpoints.getAll);
    final rows = _extractList(
      response.data,
      preferredKeys: const ['projects', 'items', 'results', 'data'],
    );
    _latestProjectCatalogRows = rows;
    if (rows.isEmpty) return const <String, String>{};

    final index = <String, String>{};
    for (final row in rows) {
      final projectId = _firstNonEmpty(<dynamic>[
        row['_id'],
        row['id'],
        row['projectId'],
      ]);
      final projectName = _firstNonEmpty(<dynamic>[
        row['projectName'],
        row['name'],
        row['title'],
      ]).toLowerCase();
      final image = _firstImageValue(<dynamic>[
        row['thumbnailUrl'],
        row['thumbnail'],
        row['thumb'],
        row['imageUrl'],
        row['image'],
        row['coverImage'],
        row['projectImage'],
        row['images'],
        row['photos'],
        row['attachments'],
      ]);

      if (image.isEmpty) continue;
      if (projectId.isNotEmpty) {
        index['id:$projectId'] = image;
      }
      if (projectName.isNotEmpty) {
        index['name:$projectName'] = image;
      }
    }
    return index;
  } catch (_) {
    _latestProjectCatalogRows = const <Map<String, dynamic>>[];
    return const <String, String>{};
  }
}

List<TaskProjectEntity> _mergeWithProjectCatalog(
  List<TaskProjectEntity> projects,
  List<Map<String, dynamic>> catalogRows,
) {
  if (catalogRows.isEmpty) return projects;

  final catalogById = <String, Map<String, dynamic>>{};
  final catalogByName = <String, Map<String, dynamic>>{};
  for (final row in catalogRows) {
    final id = _firstNonEmpty(<dynamic>[
      row['_id'],
      row['id'],
      row['projectId'],
      row['project_id'],
    ]).trim().toLowerCase();
    final name = _firstNonEmpty(<dynamic>[
      row['projectName'],
      row['name'],
      row['title'],
    ]).trim().toLowerCase();
    if (id.isNotEmpty) catalogById[id] = row;
    if (name.isNotEmpty) catalogByName[name] = row;
  }

  TaskProjectEntity enrichProject(TaskProjectEntity project) {
    final idKey = project.id.trim().toLowerCase();
    final nameKey = project.projectName.trim().toLowerCase();
    final row =
        (idKey.isNotEmpty ? catalogById[idKey] : null) ??
        (nameKey.isNotEmpty ? catalogByName[nameKey] : null);
    if (row == null) return project;

    final resolvedAddress = _firstNonEmpty(<dynamic>[
      project.projectAddress,
      row['projectAddress'],
      row['project_address'],
      row['address'],
      row['location'],
      row['city'],
      row['state'],
      row['country'],
    ]);
    final normalizedAddress = resolvedAddress.trim();
    final useAddress =
        normalizedAddress.isEmpty || normalizedAddress.toLowerCase() == 'n/a'
        ? _firstNonEmpty(<dynamic>[
            row['projectAddress'],
            row['project_address'],
            row['address'],
            row['location'],
            row['city'],
            row['state'],
            row['country'],
          ])
        : normalizedAddress;

    final existingThumb = (project.thumbnailUrl ?? '').trim();
    final resolvedThumb =
        existingThumb.isNotEmpty && existingThumb.toLowerCase() != 'null'
        ? existingThumb
        : _firstImageValue(<dynamic>[
            row['thumbnailUrl'],
            row['thumbnail'],
            row['thumb'],
            row['imageUrl'],
            row['image'],
            row['coverImage'],
            row['projectImage'],
            row['images'],
            row['photos'],
            row['attachments'],
          ]);

    if (useAddress == project.projectAddress &&
        resolvedThumb == (project.thumbnailUrl ?? '').trim()) {
      return project;
    }

    return TaskProjectModel(
      id: project.id,
      projectName: project.projectName,
      projectAddress: useAddress.isEmpty ? project.projectAddress : useAddress,
      thumbnailUrl: resolvedThumb.isEmpty
          ? project.thumbnailUrl
          : resolvedThumb,
      actionsNeededCount: project.actionsNeededCount,
      actionsNeededMessage: project.actionsNeededMessage,
      sections: project.sections,
    );
  }

  final merged = projects.map(enrichProject).toList(growable: true);

  final byId = <String, TaskProjectEntity>{};
  final byName = <String, TaskProjectEntity>{};

  for (final project in merged) {
    final id = project.id.trim().toLowerCase();
    final name = project.projectName.trim().toLowerCase();
    if (id.isNotEmpty) byId[id] = project;
    if (name.isNotEmpty) byName[name] = project;
  }

  for (final row in catalogRows) {
    final id = _firstNonEmpty(<dynamic>[
      row['_id'],
      row['id'],
      row['projectId'],
      row['project_id'],
    ]).trim();
    final name = _firstNonEmpty(<dynamic>[
      row['projectName'],
      row['name'],
      row['title'],
    ]).trim();
    if (id.isEmpty && name.isEmpty) continue;

    final idKey = id.toLowerCase();
    final nameKey = name.toLowerCase();
    if ((idKey.isNotEmpty && byId.containsKey(idKey)) ||
        (nameKey.isNotEmpty && byName.containsKey(nameKey))) {
      continue;
    }

    final address = _firstNonEmpty(<dynamic>[
      row['projectAddress'],
      row['project_address'],
      row['address'],
      row['location'],
      row['city'],
      row['state'],
      row['country'],
    ]);

    final thumbnail = _firstImageValue(<dynamic>[
      row['thumbnailUrl'],
      row['thumbnail'],
      row['thumb'],
      row['imageUrl'],
      row['image'],
      row['coverImage'],
      row['projectImage'],
      row['images'],
      row['photos'],
      row['attachments'],
    ]);

    final placeholder = TaskProjectModel(
      id: id,
      projectName: name.isEmpty ? 'Untitled Project' : name,
      projectAddress: address.isEmpty ? 'N/A' : address,
      thumbnailUrl: thumbnail.isEmpty ? null : thumbnail,
      actionsNeededCount: 0,
      actionsNeededMessage: 'No actions needed right now',
      sections: const <TaskSectionEntity>[],
    );

    if (idKey.isNotEmpty) byId[idKey] = placeholder;
    if (nameKey.isNotEmpty) byName[nameKey] = placeholder;
    merged.add(placeholder);
  }

  return merged;
}

List<TaskProjectEntity> _hydrateMissingThumbnails(
  List<TaskProjectEntity> projects,
  Map<String, String> imageIndex,
) {
  if (projects.isEmpty || imageIndex.isEmpty) return projects;

  return projects.map((project) {
    final existing = (project.thumbnailUrl ?? '').trim();
    if (existing.isNotEmpty && existing.toLowerCase() != 'null') {
      return project;
    }

    final byId = imageIndex['id:${project.id.trim()}'] ?? '';
    final byName =
        imageIndex['name:${project.projectName.trim().toLowerCase()}'] ?? '';
    final resolved = byId.isNotEmpty ? byId : byName;
    if (resolved.isEmpty) return project;

    return TaskProjectModel(
      id: project.id,
      projectName: project.projectName,
      projectAddress: project.projectAddress,
      thumbnailUrl: resolved,
      actionsNeededCount: project.actionsNeededCount,
      actionsNeededMessage: project.actionsNeededMessage,
      sections: project.sections,
    );
  }).toList();
}

bool _isTaskListPayload(List<Map<String, dynamic>> rows) {
  final first = rows.first;
  final hasProjectShape =
      first['sections'] is List ||
      first['taskSections'] is List ||
      first['groups'] is List;
  if (hasProjectShape) {
    return false;
  }

  return first.containsKey('title') ||
      first.containsKey('taskTitle') ||
      first.containsKey('priority') ||
      first.containsKey('status');
}

List<TaskProjectEntity> _buildProjectsFromTaskRows(
  List<Map<String, dynamic>> rows,
) {
  final grouped = <String, List<Map<String, dynamic>>>{};
  final projectMeta = <String, Map<String, dynamic>>{};

  for (final row in rows) {
    final project = _extractProjectMap(row);
    final projectId = _resolveProjectId(row, project);
    grouped.putIfAbsent(projectId, () => <Map<String, dynamic>>[]).add(row);
    projectMeta.putIfAbsent(projectId, () => project);
  }

  return grouped.entries.map((entry) {
    final projectId = entry.key;
    final taskRows = entry.value;
    final meta = projectMeta[projectId] ?? const <String, dynamic>{};

    final sectionRows = <String, List<Map<String, dynamic>>>{};
    for (final row in taskRows) {
      final title = _resolveSectionTitle(row);
      sectionRows.putIfAbsent(title, () => <Map<String, dynamic>>[]).add(row);
    }

    final sections = sectionRows.entries.map((sectionEntry) {
      final items = sectionEntry.value.map(TaskItemModel.fromJson).toList();
      final pendingCount = items.where((item) => !item.isFinished).length;
      return TaskSectionModel(
        title: sectionEntry.key,
        pendingCount: pendingCount,
        items: items,
      );
    }).toList();

    final actionsNeededCount = _deriveActionsNeededCountFromSections(sections);

    return TaskProjectModel(
      id: projectId == '__unassigned__' ? '' : projectId,
      projectName: _resolveProjectName(taskRows.first, meta),
      projectAddress: _resolveProjectAddress(taskRows.first, meta),
      thumbnailUrl: _resolveProjectThumbnail(taskRows.first, meta),
      actionsNeededCount: actionsNeededCount,
      actionsNeededMessage: actionsNeededCount > 0
          ? 'Your decisions are required to keep progress on track'
          : 'No actions needed right now',
      sections: sections,
    );
  }).toList();
}

int _deriveActionsNeededCountFromSections(List<TaskSectionModel> sections) {
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

Map<String, dynamic> _extractProjectMap(Map<String, dynamic> row) {
  final project = row['project'];
  if (project is Map<String, dynamic>) return project;

  final projectInfo = row['projectInfo'];
  if (projectInfo is Map<String, dynamic>) return projectInfo;

  return const <String, dynamic>{};
}

String _resolveProjectId(
  Map<String, dynamic> row,
  Map<String, dynamic> project,
) {
  final fromProject = _firstNonEmpty(<dynamic>[
    project['_id'],
    project['id'],
    project['projectId'],
    project['project_id'],
  ]);
  if (fromProject.isNotEmpty) return fromProject;

  final direct = row['project'];
  if (direct is String && direct.trim().isNotEmpty) return direct.trim();

  final fromRow = _firstNonEmpty(<dynamic>[
    row['projectId'],
    row['project_id'],
    row['projectID'],
    row['_projectId'],
  ]);
  if (fromRow.isNotEmpty) return fromRow;

  // Some payloads omit stable project ids; use project identity fields
  // so dropdown grouping still works per project instead of collapsing all.
  final projectIdentity = _firstNonEmpty(<dynamic>[
    row['projectName'],
    row['project_name'],
    row['projectTitle'],
    project['projectName'],
    project['name'],
    project['title'],
  ]);
  if (projectIdentity.isNotEmpty) {
    return '__project__${projectIdentity.trim().toLowerCase()}';
  }

  return '__unassigned__';
}

String _resolveProjectName(
  Map<String, dynamic> row,
  Map<String, dynamic> project,
) {
  final value = _firstNonEmpty(<dynamic>[
    row['projectName'],
    row['project_name'],
    row['name'],
    project['projectName'],
    project['name'],
    project['title'],
  ]);
  return value.isEmpty ? 'Untitled Project' : value;
}

String _resolveProjectAddress(
  Map<String, dynamic> row,
  Map<String, dynamic> project,
) {
  final value = _firstNonEmpty(<dynamic>[
    row['projectAddress'],
    row['project_address'],
    row['address'],
    row['location'],
    row['city'],
    row['state'],
    row['country'],
    project['projectAddress'],
    project['project_address'],
    project['address'],
    project['location'],
    project['city'],
    project['state'],
    project['country'],
  ]);
  return value.isEmpty ? 'N/A' : value;
}

String? _resolveProjectThumbnail(
  Map<String, dynamic> row,
  Map<String, dynamic> project,
) {
  final value = _firstImageValue(<dynamic>[
    row['thumbnailUrl'],
    row['thumbnail'],
    row['thumb'],
    row['imageUrl'],
    row['image'],
    row['coverImage'],
    row['projectImage'],
    row['images'],
    row['photos'],
    row['attachments'],
    project['thumbnailUrl'],
    project['thumbnail'],
    project['thumb'],
    project['imageUrl'],
    project['image'],
    project['coverImage'],
    project['projectImage'],
    project['images'],
    project['photos'],
    project['attachments'],
  ]);
  return value.isEmpty ? null : value;
}

String _resolveSectionTitle(Map<String, dynamic> row) {
  final value = _firstNonEmpty(<dynamic>[
    row['section'],
    row['sectionName'],
    row['group'],
    row['groupName'],
    row['category'],
    row['phase'],
    row['phaseName'],
  ]);
  return value.isEmpty ? 'Your Actions' : value;
}

String _firstNonEmpty(List<dynamic> values) {
  for (final value in values) {
    final text = _extractText(value);
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _firstImageValue(List<dynamic> values) {
  for (final value in values) {
    final text = _extractImageText(value);
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _extractText(dynamic value) {
  if (value == null) return '';

  if (value is String) {
    final trimmed = value.trim();
    return trimmed.toLowerCase() == 'null' ? '' : trimmed;
  }

  if (value is num || value is bool) {
    return value.toString();
  }

  if (value is Map) {
    final city = _extractText(value['city']);
    final state = _extractText(value['state']);
    final country = _extractText(value['country']);
    final addressParts = <String>[
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (country.isNotEmpty) country,
    ];
    if (addressParts.isNotEmpty) {
      return addressParts.join(', ');
    }

    const preferredKeys = <String>[
      'id',
      '_id',
      'projectId',
      'projectAddress',
      'project_address',
      'address',
      'name',
      'title',
      'url',
      'imageUrl',
      'image_url',
      'secureUrl',
      'secure_url',
      'src',
      'path',
      'location',
    ];
    for (final key in preferredKeys) {
      final candidate = _extractText(value[key]);
      if (candidate.isNotEmpty) return candidate;
    }
    return '';
  }

  if (value is List) {
    for (final item in value) {
      final candidate = _extractText(item);
      if (candidate.isNotEmpty) return candidate;
    }
    return '';
  }

  return '';
}

String _extractImageText(dynamic value) {
  if (value == null) return '';

  if (value is String) {
    final trimmed = value.trim();
    return trimmed.toLowerCase() == 'null' ? '' : trimmed;
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
      'thumbnailUrl',
      'thumbnail',
      'thumb',
      'coverImage',
      'image',
      'projectImage',
    ];
    for (final key in imageKeys) {
      final candidate = _extractImageText(value[key]);
      if (candidate.isNotEmpty) return candidate;
    }
    return '';
  }

  if (value is List) {
    for (final item in value) {
      final candidate = _extractImageText(item);
      if (candidate.isNotEmpty) return candidate;
    }
    return '';
  }

  return '';
}

Map<String, dynamic> _extractMap(
  dynamic payload, {
  List<String> preferredKeys = const <String>[],
}) {
  if (payload is Map<String, dynamic>) {
    for (final key in preferredKeys) {
      final value = payload[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      for (final key in preferredKeys) {
        final nested = data[key];
        if (nested is Map<String, dynamic>) {
          return nested;
        }
      }
      return data;
    }

    return payload;
  }

  throw DioException(
    requestOptions: RequestOptions(path: ''),
    error: 'Invalid response payload',
  );
}

List<Map<String, dynamic>> _extractList(
  dynamic payload, {
  List<String> preferredKeys = const <String>[],
}) {
  if (payload is List) {
    return payload.whereType<Map<String, dynamic>>().toList();
  }

  if (payload is! Map<String, dynamic>) {
    return const <Map<String, dynamic>>[];
  }

  for (final key in preferredKeys) {
    final value = payload[key];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    if (value is Map<String, dynamic>) {
      final nested = _extractList(value, preferredKeys: preferredKeys);
      if (nested.isNotEmpty) {
        return nested;
      }
    }
  }

  final data = payload['data'];
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().toList();
  }
  if (data is Map<String, dynamic>) {
    return _extractList(data, preferredKeys: preferredKeys);
  }

  return const <Map<String, dynamic>>[];
}
