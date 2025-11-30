import 'package:gitpulse/models/github_repo.dart';

class RunResult {
  final GithubRepo repo;
  final int requestedMarkers;
  final int markersAdded;
  final bool success;
  final String? errorMessage;
  final Duration duration;

  const RunResult({
    required this.repo,
    required this.requestedMarkers,
    required this.markersAdded,
    required this.success,
    required this.duration,
    this.errorMessage,
  });
}
