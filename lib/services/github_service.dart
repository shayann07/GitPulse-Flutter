import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/github_repo.dart';
import '../models/run_result.dart';

class GithubService {
  GithubService._internal();

  static final GithubService instance = GithubService._internal();

  static const String _baseUrl = 'https://api.github.com';

  // EXISTING:
  Future<List<GithubRepo>> fetchUserRepos({
    required String accessToken,
    required bool includePrivate,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/user/repos?affiliation=owner&per_page=100',
    );

    final resp = await http.get(
      uri,
      headers: {
        'Authorization': 'token $accessToken',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch repos: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body) as List<dynamic>;

    final repos = decoded
        .map((e) => GithubRepo.fromJson(e as Map<String, dynamic>))
        .where((repo) {
          if (repo.isArchived || repo.isFork || !repo.canPush) return false;
          // includePrivate is used only to *filter* later; here we keep both
          // and let the caller decide.
          return true;
        })
        .toList();

    // NOTE: filtering on includePrivate is handled by the caller / RunService.
    return repos;
  }

  // =========================================================
  //  RUN ENGINE
  //  - Pick random eligible repo
  //  - GET README
  //  - Parse <!-- commit N -->
  //  - PUT README for each marker (1 commit per marker)
  // =========================================================

  Future<RunResult> runGitPulseOnRandomRepo({
    required String accessToken,
    required List<GithubRepo> eligibleRepos,
    required int markersToAdd,
    required String commitMessage,
  }) async {
    if (eligibleRepos.isEmpty) {
      throw StateError('No eligible repositories to run on.');
    }

    final startedAt = DateTime.now();
    final client = http.Client();

    try {
      final candidates = [...eligibleRepos]..shuffle(Random());

      _InternalRunResult? chosen;

      for (final repo in candidates) {
        final result = await _runOnSingleRepo(
          client: client,
          accessToken: accessToken,
          repo: repo,
          markersToAdd: markersToAdd,
          commitMessage: commitMessage,
        );

        // If we successfully added *anything* or hit a meaningful API error,
        // stop trying other repos. Only keep skipping for missing README.
        if (!result.readmeMissing) {
          chosen = result;
          break;
        }
      }

      chosen ??= _InternalRunResult(
        repo: candidates.first,
        requestedMarkers: markersToAdd,
        markersAdded: 0,
        success: false,
        errorMessage: 'No repository with an editable README.md was found.',
        readmeMissing: true,
      );

      return RunResult(
        repo: chosen.repo,
        requestedMarkers: chosen.requestedMarkers,
        markersAdded: chosen.markersAdded,
        success: chosen.success,
        errorMessage: chosen.errorMessage,
        duration: DateTime.now().difference(startedAt),
      );
    } finally {
      client.close();
    }
  }

  Future<_InternalRunResult> _runOnSingleRepo({
    required http.Client client,
    required String accessToken,
    required GithubRepo repo,
    required int markersToAdd,
    required String commitMessage,
  }) async {
    _ReadmeFile? readme;

    try {
      readme = await _fetchReadme(
        client: client,
        accessToken: accessToken,
        repo: repo,
      );
    } on _ReadmeNotFoundException {
      return _InternalRunResult(
        repo: repo,
        requestedMarkers: markersToAdd,
        markersAdded: 0,
        success: false,
        errorMessage: 'README.md not found for ${repo.fullName}',
        readmeMissing: true,
      );
    }

    final regex = RegExp(r'<!--\s*commit\s+(\d+)\s*-->', caseSensitive: false);
    int maxMarker = 0;

    for (final m in regex.allMatches(readme.content)) {
      final raw = m.group(1);
      final n = int.tryParse(raw ?? '');
      if (n != null && n > maxMarker) maxMarker = n;
    }

    var content = readme.content;
    var sha = readme.sha;

    int markersAdded = 0;
    String? lastError;

    for (var i = 0; i < markersToAdd; i++) {
      final nextNumber = maxMarker + 1 + markersAdded;
      content = _appendMarker(content, nextNumber);

      final encoded = base64Encode(utf8.encode(content));

      final uri = Uri.parse(
        '$_baseUrl/repos/${repo.owner}/${repo.name}/contents/${readme?.path}',
      );

      final resp = await client.put(
        uri,
        headers: {
          'Authorization': 'token $accessToken',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': commitMessage,
          'content': encoded,
          'sha': sha,
        }),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        sha = (body['content']?['sha'] as String?) ?? sha;
        markersAdded++;
        continue;
      }

      // 409: SHA mismatch – reload README and retry remaining markers.
      if (resp.statusCode == 409) {
        try {
          readme = await _fetchReadme(
            client: client,
            accessToken: accessToken,
            repo: repo,
          );
          content = readme.content;
          sha = readme.sha;

          // Recompute max marker from fresh content to avoid duplicates.
          maxMarker = 0;
          for (final m in regex.allMatches(content)) {
            final raw = m.group(1);
            final n = int.tryParse(raw ?? '');
            if (n != null && n > maxMarker) maxMarker = n;
          }

          // redo this iteration with new base content
          i--;
          continue;
        } catch (e) {
          lastError = 'Conflict while refreshing README: $e';
          break;
        }
      }

      // 403 – rate limit or scope issues
      if (resp.statusCode == 403 &&
          resp.body.toLowerCase().contains('rate limit')) {
        lastError = 'GitHub API rate limit exceeded. Please try again later.';
        break;
      }

      if (resp.statusCode == 401 || resp.statusCode == 403) {
        lastError =
            'GitHub authorization failed (status ${resp.statusCode}). Please re-login.';
        break;
      }

      lastError = 'GitHub error ${resp.statusCode}: ${resp.body}';
      break;
    }

    final success = markersAdded == markersToAdd;

    return _InternalRunResult(
      repo: repo,
      requestedMarkers: markersToAdd,
      markersAdded: markersAdded,
      success: success,
      errorMessage: lastError,
      readmeMissing: false,
    );
  }

  Future<_ReadmeFile> _fetchReadme({
    required http.Client client,
    required String accessToken,
    required GithubRepo repo,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/${repo.owner}/${repo.name}/contents/README.md',
    );

    final resp = await client.get(
      uri,
      headers: {
        'Authorization': 'token $accessToken',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (resp.statusCode == 404) {
      throw _ReadmeNotFoundException();
    }

    if (resp.statusCode != 200) {
      throw Exception(
        'Failed to fetch README: ${resp.statusCode} ${resp.body}',
      );
    }

    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    var b64 = (map['content'] as String? ?? '').replaceAll('\n', '');
    final decoded = utf8.decode(base64Decode(b64));

    return _ReadmeFile(
      path: (map['path'] as String?) ?? 'README.md',
      sha: map['sha'] as String,
      content: decoded,
    );
  }

  String _appendMarker(String content, int markerNumber) {
    final marker = '\n<!-- commit $markerNumber -->\n';
    if (content.endsWith('\n')) {
      return '$content<!-- commit $markerNumber -->\n';
    } else {
      return '$content$marker';
    }
  }
}

class _ReadmeFile {
  final String path;
  final String sha;
  final String content;

  const _ReadmeFile({
    required this.path,
    required this.sha,
    required this.content,
  });
}

class _InternalRunResult {
  final GithubRepo repo;
  final int requestedMarkers;
  final int markersAdded;
  final bool success;
  final String? errorMessage;
  final bool readmeMissing;

  const _InternalRunResult({
    required this.repo,
    required this.requestedMarkers,
    required this.markersAdded,
    required this.success,
    required this.errorMessage,
    required this.readmeMissing,
  });
}

class _ReadmeNotFoundException implements Exception {}
