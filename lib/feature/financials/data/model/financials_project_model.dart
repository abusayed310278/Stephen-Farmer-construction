import '../../domain/entities/financials_project_entity.dart';

class PaymentScheduleItemModel extends PaymentScheduleItemEntity {
  const PaymentScheduleItemModel({
    required super.title,
    required super.dateLabel,
    required super.amount,
    required super.isPaid,
  });

  factory PaymentScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return PaymentScheduleItemModel(
      title: _readString(json, ["title", "name"], fallback: "Payment"),
      dateLabel: _readString(json, ["dateLabel", "date"], fallback: ""),
      amount: _readInt(json, ["amount", "value"], fallback: 0),
      isPaid: _readBool(json, ["isPaid", "paid"], fallback: false),
    );
  }
}

class PaymentScheduleSectionModel extends PaymentScheduleSectionEntity {
  const PaymentScheduleSectionModel({
    required super.title,
    required super.items,
  });

  factory PaymentScheduleSectionModel.fromJson(Map<String, dynamic> json) {
    final rows = json["items"];
    final items = rows is List
        ? rows
              .whereType<Map<String, dynamic>>()
              .map(PaymentScheduleItemModel.fromJson)
              .toList()
        : <PaymentScheduleItemModel>[];

    return PaymentScheduleSectionModel(
      title: _readString(json, ["title", "name"], fallback: "Payment Section"),
      items: items,
    );
  }
}

class FinancialsProjectModel extends FinancialsProjectEntity {
  const FinancialsProjectModel({
    required super.id,
    required super.projectName,
    required super.projectAddress,
    super.thumbnailUrl,
    required super.totalBudget,
    required super.paidToDate,
    required super.remainingBalance,
    required super.paidPercent,
    required super.scheduleSections,
  });

  factory FinancialsProjectModel.fromJson(Map<String, dynamic> json) {
    final project = json["project"] is Map<String, dynamic>
        ? json["project"] as Map<String, dynamic>
        : const <String, dynamic>{};
    final sectionRows =
        json["scheduleSections"] ?? json["schedules"] ?? json["schedule"];
    final sections = sectionRows is List
        ? sectionRows
              .whereType<Map<String, dynamic>>()
              .map(PaymentScheduleSectionModel.fromJson)
              .toList()
        : <PaymentScheduleSectionModel>[];

    final phasesRaw = json["phases"];
    final phases = phasesRaw is List
        ? phasesRaw.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    final scheduleFromPhases = phases.isEmpty
        ? <PaymentScheduleSectionModel>[]
        : _buildScheduleFromPhases(phases);
    final resolvedSections = sections.isNotEmpty
        ? sections
        : scheduleFromPhases;

    final totalBudget = _readInt(json, [
      "totalBudget",
      "projectBudget",
      "budget",
    ], fallback: 0);
    final paidToDate = _readInt(json, [
      "paidToDate",
      "totalPaid",
      "paidAmount",
      "totalPaid",
    ], fallback: 0);
    final remainingBalance = _readInt(json, [
      "remainingBalance",
      "remainingBudget",
      "remainingAmount",
    ], fallback: 0);
    final paidPercent = _readPercent(
      json,
      ["paidPercent", "paidPercentage", "paid_percentage"],
      totalBudget: totalBudget,
      paidToDate: paidToDate,
    );

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

    return FinancialsProjectModel(
      id: _readString(json, ["_id", "id", "projectId"]),
      projectName: _readString(json, [
        "projectName",
        "name",
        "title",
      ], fallback: "Untitled Project"),
      projectAddress: _readString(json, [
        "projectAddress",
        "address",
        "location",
      ], fallback: "N/A"),
      thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
      totalBudget: totalBudget,
      paidToDate: paidToDate,
      remainingBalance: remainingBalance,
      paidPercent: paidPercent,
      scheduleSections: resolvedSections,
    );
  }

  static const List<FinancialsProjectModel> dummyData = [
    FinancialsProjectModel(
      id: "demo-1",
      projectName: "Riverside Apartment Renovation",
      projectAddress: "42 Harbor View Drive, Apt 8",
      thumbnailUrl:
          "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&auto=format&fit=crop",
      totalBudget: 166130,
      paidToDate: 92500,
      remainingBalance: 93630,
      paidPercent: 50,
      scheduleSections: [
        PaymentScheduleSectionModel(
          title: "Paid Amount",
          items: [
            PaymentScheduleItemModel(
              title: "Deposit",
              dateLabel: "Dec 1, 2024",
              amount: 37000,
              isPaid: true,
            ),
            PaymentScheduleItemModel(
              title: "Structural Completion",
              dateLabel: "Jan 15, 2025",
              amount: 37000,
              isPaid: true,
            ),
            PaymentScheduleItemModel(
              title: "Rough-in Completion",
              dateLabel: "Feb 1, 2025",
              amount: 37000,
              isPaid: true,
            ),
          ],
        ),
        PaymentScheduleSectionModel(
          title: "Due Amount",
          items: [
            PaymentScheduleItemModel(
              title: "Cabinetry Installation",
              dateLabel: "Feb 15, 2025",
              amount: 37000,
              isPaid: false,
            ),
            PaymentScheduleItemModel(
              title: "Cabinetry Installation",
              dateLabel: "Feb 15, 2025",
              amount: 37000,
              isPaid: false,
            ),
            PaymentScheduleItemModel(
              title: "Cabinetry Installation",
              dateLabel: "Feb 15, 2025",
              amount: 37000,
              isPaid: false,
            ),
          ],
        ),
      ],
    ),
    FinancialsProjectModel(
      id: "demo-2",
      projectName: "Cityline Duplex Build",
      projectAddress: "15 Lakefront Ave, Unit 12",
      thumbnailUrl:
          "https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=400&auto=format&fit=crop",
      totalBudget: 220000,
      paidToDate: 120000,
      remainingBalance: 100000,
      paidPercent: 55,
      scheduleSections: [
        PaymentScheduleSectionModel(
          title: "Paid Amount",
          items: [
            PaymentScheduleItemModel(
              title: "Initial Advance",
              dateLabel: "Nov 25, 2024",
              amount: 60000,
              isPaid: true,
            ),
            PaymentScheduleItemModel(
              title: "Framing Completion",
              dateLabel: "Jan 10, 2025",
              amount: 60000,
              isPaid: true,
            ),
          ],
        ),
        PaymentScheduleSectionModel(
          title: "Due Amount",
          items: [
            PaymentScheduleItemModel(
              title: "Interior Finishing",
              dateLabel: "Mar 2, 2025",
              amount: 50000,
              isPaid: false,
            ),
            PaymentScheduleItemModel(
              title: "Final Handover",
              dateLabel: "Apr 5, 2025",
              amount: 50000,
              isPaid: false,
            ),
          ],
        ),
      ],
    ),
  ];
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

int _readInt(Map<String, dynamic> json, List<String> keys, {int fallback = 0}) {
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

int _readPercent(
  Map<String, dynamic> json,
  List<String> keys, {
  required int totalBudget,
  required int paidToDate,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed.round();
    }
  }
  if (totalBudget <= 0) return 0;
  return ((paidToDate / totalBudget) * 100).round();
}

List<PaymentScheduleSectionModel> _buildScheduleFromPhases(
  List<Map<String, dynamic>> phases,
) {
  final paid = <PaymentScheduleItemModel>[];
  final due = <PaymentScheduleItemModel>[];

  for (final phase in phases) {
    final name = _readString(phase, [
      "phaseName",
      "title",
      "name",
    ], fallback: "Phase");
    final amount = _readInt(phase, ["amount", "value"], fallback: 0);
    final paymentStatus = _readString(phase, [
      "paymentStatus",
      "status",
    ], fallback: "unpaid").toLowerCase();
    final isPaid = paymentStatus == "paid";

    final dueDateLabel = _readDateLabel(phase["dueDate"] ?? phase["due_date"]);
    final paidAtLabel = _readDateLabel(phase["paidAt"] ?? phase["paid_at"]);
    final dateLabel = (isPaid ? paidAtLabel : dueDateLabel).trim().isEmpty
        ? (dueDateLabel.trim().isEmpty ? "" : dueDateLabel)
        : (isPaid ? paidAtLabel : dueDateLabel);

    final item = PaymentScheduleItemModel(
      title: name,
      dateLabel: dateLabel,
      amount: amount,
      isPaid: isPaid,
    );

    if (isPaid) {
      paid.add(item);
    } else {
      due.add(item);
    }
  }

  return [
    if (paid.isNotEmpty)
      PaymentScheduleSectionModel(title: "Paid Amount", items: paid),
    if (due.isNotEmpty)
      PaymentScheduleSectionModel(title: "Due Amount", items: due),
  ];
}

String _readDateLabel(dynamic value) {
  if (value == null) return "";
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return "";
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) return _formatYmd(parsed);
    return trimmed;
  }
  if (value is int) {
    final dt = _tryParseEpoch(value);
    return dt == null ? "" : _formatYmd(dt);
  }
  if (value is double) {
    final dt = _tryParseEpoch(value.round());
    return dt == null ? "" : _formatYmd(dt);
  }
  return value.toString();
}

DateTime? _tryParseEpoch(int value) {
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

bool _readBool(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == "true") return true;
      if (normalized == "false") return false;
    }
    if (value is int) {
      if (value == 1) return true;
      if (value == 0) return false;
    }
  }
  return fallback;
}
