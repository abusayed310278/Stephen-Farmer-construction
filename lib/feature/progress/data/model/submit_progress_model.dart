class SubmitProgressRequestModel {
  final String progressName;
  final int percent;
  final String note;

  const SubmitProgressRequestModel({
    required this.progressName,
    required this.percent,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      "progressName": progressName,
      "percent": percent,
      "note": note,
    };
  }
}
