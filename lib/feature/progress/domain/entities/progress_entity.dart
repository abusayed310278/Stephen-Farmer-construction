class ProgressTaskEntity {
  final String title;
  final String status;
  final int progressPercent;
  final String? dateLabel;

  const ProgressTaskEntity({
    required this.title,
    required this.status,
    required this.progressPercent,
    this.dateLabel,
  });
}

class ProgressUpdateEntity extends ProgressTaskEntity {
  final String id;
  final String note;
  final String updatedBy;

  const ProgressUpdateEntity({
    required this.id,
    required String progressName,
    required int percent,
    required this.note,
    required this.updatedBy,
    String? updatedAtLabel,
  }) : super(
          title: progressName,
          status: percent >= 100 ? 'Completed' : 'In Progress',
          progressPercent: percent,
          dateLabel: updatedAtLabel,
        );
}

class ProjectProgressEntity {
  final String id;
  final String name;
  final String address;
  final String heroImageUrl;
  final String? thumbnailUrl;
  final int overallCompletion;
  final int dayCurrent;
  final int dayTotal;
  final int tasksCompleted;
  final int tasksTotal;
  final int photosTotal;
  final String startedDate;
  final String handoverDate;
  final List<ProgressTaskEntity> tasks;
  final List<ProgressUpdateEntity> updates;

  const ProjectProgressEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.heroImageUrl,
    this.thumbnailUrl,
    required this.overallCompletion,
    required this.dayCurrent,
    required this.dayTotal,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.photosTotal,
    required this.startedDate,
    required this.handoverDate,
    required this.tasks,
    required this.updates,
  });
}
