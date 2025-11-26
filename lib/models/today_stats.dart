class TodayStats {
  final int totalCommits;
  final int totalSessions;
  final int successfulSessions;

  const TodayStats({
    required this.totalCommits,
    required this.totalSessions,
    required this.successfulSessions,
  });

  double get successRate {
    if (totalSessions == 0) return 0;
    return successfulSessions * 100.0 / totalSessions;
  }

  static const empty =
  TodayStats(totalCommits: 0, totalSessions: 0, successfulSessions: 0);
}
