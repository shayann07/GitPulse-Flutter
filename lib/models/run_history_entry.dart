class RunHistoryEntry {
  final String id;
  final DateTime timestamp;
  final String repoName;
  final String owner;
  final String fullName;
  final int markersRequested;
  final int markersAdded;
  final bool success;
  final String? errorMessage;

  const RunHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.repoName,
    required this.owner,
    required this.fullName,
    required this.markersRequested,
    required this.markersAdded,
    required this.success,
    this.errorMessage,
  });

  bool get isPartial =>
      !success && markersAdded > 0 && markersAdded < markersRequested;

  bool get isFailed => !success && markersAdded == 0;

  double get completionRatio {
    if (markersRequested <= 0) return 1.0;
    return markersAdded / markersRequested;
  }
}
