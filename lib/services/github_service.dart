import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/github_repo.dart';

class GithubService {
  GithubService._internal();
  static final GithubService instance = GithubService._internal();

  static const String _baseUrl = 'https://api.github.com';

  Future<List<GithubRepo>> fetchUserRepos({
    required String accessToken,
    required bool includePrivate,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/user/repos?per_page=100&affiliation=owner',
    );

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load repositories (${res.statusCode})');
    }

    final List<dynamic> decoded = jsonDecode(res.body) as List<dynamic>;

    final repos = decoded
        .map((e) => GithubRepo.fromJson(e as Map<String, dynamic>))
        .where((repo) {
      // Filter per spec: owner repos only (affiliation=owner already),
      // exclude org-owned, archived, forks, no push permission.
      if (repo.isArchived || repo.isFork || !repo.canPush) return false;
      if (!includePrivate && repo.isPrivate) return false;
      return true;
    }).toList();

    return repos;
  }
}
