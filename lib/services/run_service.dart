import 'package:gitpulse/models/github_repo.dart';
import 'package:gitpulse/models/run_result.dart';
import 'package:gitpulse/models/session_data.dart';
import 'package:gitpulse/models/user_settings.dart';
import 'package:gitpulse/services/firestore_service.dart';
import 'package:gitpulse/services/github_service.dart';

class DailyLimitExceededException implements Exception {
  final int maxPerDay;

  const DailyLimitExceededException({this.maxPerDay = 500});

  @override
  String toString() => 'Daily limit of $maxPerDay commits reached or exceeded.';
}

class NoEligibleReposException implements Exception {
  @override
  String toString() =>
      'No eligible repositories selected. Please update your repo selection.';
}

class RunService {
  RunService._internal();

  static final RunService instance = RunService._internal();

  static const int _dailyLimit = 500;

  Future<RunResult> runNow({
    required SessionData session,
    required UserSettings settings,
    required List<GithubRepo> allRepos,
  }) async {
    // 1) eligible repos (as you already do)
    final eligible = allRepos.where((repo) {
      final key = repo.fullName;
      final explicit = settings.repoSelections[key];

      if (explicit != null) return explicit;
      if (!settings.includePrivate && repo.isPrivate) return false;
      return true;
    }).toList();

    if (eligible.isEmpty) {
      // This is a “run never started” type of failure — we *can* log it if you want,
      // but for now we keep throwing.
      throw NoEligibleReposException();
    }

    // 2) daily limit
    final todayStats = await FirestoreService.instance.fetchTodayStats(
      session.uid,
    );
    final usedToday = todayStats.totalCommits;
    final remaining = _dailyLimit - usedToday;

    if (remaining <= 0) {
      throw DailyLimitExceededException(maxPerDay: _dailyLimit);
    }

    final markersToAdd = settings.commitsPerRun > remaining
        ? remaining
        : settings.commitsPerRun;

    final message = _templateToMessage(settings.templateId);
    final startedAt = DateTime.now();

    RunResult result;

    try {
      // 3) Try GitHub run normally
      final ghResult = await GithubService.instance.runGitPulseOnRandomRepo(
        accessToken: session.accessToken,
        eligibleRepos: eligible,
        markersToAdd: markersToAdd,
        commitMessage: message,
      );

      result = ghResult;
    } catch (e) {
      // 4) Something exploded (like you turning off internet).
      // We still build a failed RunResult so we can log it.
      final repoForLog = eligible.first; // or pick random if you prefer

      result = RunResult(
        repo: repoForLog,
        requestedMarkers: markersToAdd,
        markersAdded: 0,
        success: false,
        duration: DateTime.now().difference(startedAt),
        errorMessage: e.toString(),
      );
    }

    final endedAt = DateTime.now();

    // 5) Try to log the run – even if we’re offline, Firestore will queue it.
    try {
      await FirestoreService.instance.logRunSession(
        uid: session.uid,
        repo: result.repo,
        markersRequested: result.requestedMarkers,
        markersAdded: result.markersAdded,
        success: result.success,
        errorMessage: result.errorMessage,
        startedAt: startedAt,
        endedAt: endedAt,
      );
    } catch (_) {
      // Don’t crash the app if logging itself fails.
      // Worst case: run isn’t stored – but at least we *tried*.
    }

    return result;
  }

  String _templateToMessage(String templateId) {
    switch (templateId) {
      case 'default':
        return 'Update README markers [GitPulse]';
      case 'auto':
        return 'Automated marker commit [GitPulse]';
      case 'sync':
        return 'Marker sync: README update [GitPulse]';
      default:
        return 'Update README markers [GitPulse]';
    }
  }
}
