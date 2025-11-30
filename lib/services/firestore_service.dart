import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/github_repo.dart';
import '../models/run_history_entry.dart';
import '../models/today_stats.dart';
import '../models/user_profile.dart';
import '../models/user_settings.dart';

class FirestoreService {
  FirestoreService._internal();

  static final FirestoreService instance = FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<UserProfile?> fetchUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return UserProfile.fromMap(uid, data);
  }

  Future<UserSettings> fetchUserSettings(String uid) async {
    final doc = await _users.doc(uid).get();
    final data = doc.data();
    if (data == null) return UserSettings.defaults;

    final settingsRaw =
        (data['settings'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final commitsPerRun = settingsRaw['commitsPerRun'] as int? ?? 10;
    final includePrivate = settingsRaw['includePrivate'] as bool? ?? true;
    final templateId = settingsRaw['templateId'] as String? ?? 'default';

    final rawSelections =
        (settingsRaw['repoSelections'] as Map<String, dynamic>?) ??
        <String, dynamic>{};

    final repoSelections = rawSelections.map(
      (key, value) => MapEntry(key.toString(), value == true),
    );

    return UserSettings(
      commitsPerRun: commitsPerRun,
      includePrivate: includePrivate,
      templateId: templateId,
      repoSelections: repoSelections,
    );
  }

  Future<void> updateRepoSelection({
    required String uid,
    required String repoKey,
    required bool selected,
  }) async {
    // Nested field path: settings.repoSelections.<repoKey>
    await _users.doc(uid).set({
      'settings': {
        'repoSelections': {repoKey: selected},
      },
    }, SetOptions(merge: true));
  }

  Future<void> logRunSession({
    required String uid,
    required GithubRepo repo,
    required int markersRequested,
    required int markersAdded,
    required bool success,
    String? errorMessage,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final userRef = _users.doc(uid);
    final historyRef = userRef.collection('history');

    final nowUtc = DateTime.now().toUtc();
    final durationMs = endedAt.difference(startedAt).inMilliseconds;

    final sessionDoc = historyRef.doc();

    await sessionDoc.set({
      'timestamp': nowUtc,
      'repoName': repo.name,
      'owner': repo.owner,
      'fullName': repo.fullName,
      'markersRequested': markersRequested,
      'markersAdded': markersAdded,
      'success': success,
      'errorMessage': errorMessage,
      'durationMs': durationMs,
    });

    // dailyCounters.yyyy-mm-dd += markersAdded
    final dayKey = _dayKey(nowUtc);

    await userRef.set(
      {
        'dailyCounters': {dayKey: FieldValue.increment(markersAdded)},
      },
      SetOptions(merge: true),
    ); // FieldValue.increment is atomic :contentReference[oaicite:8]{index=8}
  }

  String _dayKey(DateTime utc) {
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<List<RunHistoryEntry>> fetchRunHistory(
    String uid, {
    int limit = 50,
  }) async {
    final historyRef = _users.doc(uid).collection('history');

    final snapshot = await historyRef
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

      return RunHistoryEntry(
        id: doc.id,
        timestamp: ts.toUtc(),
        repoName: data['repoName'] as String? ?? '',
        owner: data['owner'] as String? ?? '',
        fullName: data['fullName'] as String? ?? '',
        markersRequested: data['markersRequested'] as int? ?? 0,
        markersAdded: data['markersAdded'] as int? ?? 0,
        success: data['success'] as bool? ?? false,
        errorMessage: data['errorMessage'] as String?,
      );
    }).toList();
  }

  Future<TodayStats> fetchTodayStats(String uid) async {
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(now.year, now.month, now.day);

    final historyRef = _users.doc(uid).collection('history');

    final query = await historyRef
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();

    int commits = 0;
    int sessions = 0;
    int success = 0;

    for (final doc in query.docs) {
      final data = doc.data();
      commits += (data['markersAdded'] as int?) ?? 0;
      sessions++;
      if (data['success'] == true) success++;
    }

    return TodayStats(
      totalCommits: commits,
      totalSessions: sessions,
      successfulSessions: success,
    );
  }
}
