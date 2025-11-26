import 'package:cloud_firestore/cloud_firestore.dart';

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
