import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/session_data.dart';
import '../models/user_profile.dart';
import '../models/user_settings.dart';
import '../models/github_repo.dart';
import '../models/today_stats.dart';
import '../services/firestore_service.dart';
import '../services/github_service.dart';

/// Reads token + uid from secure storage and exposes them.
final sessionProvider = FutureProvider<SessionData?>((ref) async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'github_access_token');
  final uid = await storage.read(key: 'github_user_id');

  if (token == null || uid == null) return null;
  return SessionData(uid: uid, accessToken: token);
});

/// User profile from Firestore.
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final session = await ref.watch(sessionProvider.future);
  if (session == null) return null;
  return FirestoreService.instance.fetchUserProfile(session.uid);
});

/// User settings from Firestore.
final userSettingsProvider = FutureProvider<UserSettings>((ref) async {
  final session = await ref.watch(sessionProvider.future);
  if (session == null) return UserSettings.defaults;
  return FirestoreService.instance.fetchUserSettings(session.uid);
});

/// GitHub repos for the user (filtered per settings).
final reposProvider = FutureProvider<List<GithubRepo>>((ref) async {
  final session = await ref.watch(sessionProvider.future);
  if (session == null) return <GithubRepo>[];

  final settings = await ref.watch(userSettingsProvider.future);

  return GithubService.instance.fetchUserRepos(
    accessToken: session.accessToken,
    includePrivate: settings.includePrivate,
  );
});

/// Today’s stats (commits + success rate) from Firestore history.
final todayStatsProvider = FutureProvider<TodayStats>((ref) async {
  final session = await ref.watch(sessionProvider.future);
  if (session == null) return TodayStats.empty;
  return FirestoreService.instance.fetchTodayStats(session.uid);
});
