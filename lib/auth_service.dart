import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginResult {
  final bool success;
  final String? errorMessage;

  const LoginResult({required this.success, this.errorMessage});
}

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // MUST be your real GitHub OAuth app values.
  static const String _clientId = 'Ov23liJJGjeRyCdLF256';
  static const String _clientSecret = '3d353f3b931f97f973911bca493df375c615041e';
  static const String _redirectUrl = "gitpulse://auth";

  static final AuthorizationServiceConfiguration _githubConfig =
  const AuthorizationServiceConfiguration(
    authorizationEndpoint: 'https://github.com/login/oauth/authorize',
    tokenEndpoint: 'https://github.com/login/oauth/access_token',
  );

  Future<LoginResult> loginWithGitHub() async {
    try {
      // 1) Start OAuth + exchange code for token
      final AuthorizationTokenResponse? authResult =
      await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          clientSecret: _clientSecret, // <<< IMPORTANT: include client secret
          serviceConfiguration: _githubConfig,
          scopes: [
            'repo',
            'read:user',
            'user:email',
          ],
        ),
      );

      if (authResult == null || authResult.accessToken == null) {
        return const LoginResult(
          success: false,
          errorMessage: 'Login was cancelled.',
        );
      }

      final accessToken = authResult.accessToken!;

      // 2) Fetch GitHub user profile
      final userRes = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/vnd.github+json',
        },
      );

      if (userRes.statusCode != 200) {
        return const LoginResult(
          success: false,
          errorMessage: 'Could not fetch your GitHub profile.',
        );
      }

      final userJson = jsonDecode(userRes.body);
      final githubId = userJson['id'].toString();
      final username = userJson['login'] ?? '';
      final avatarUrl = userJson['avatar_url'];
      final email = userJson['email'];

      final userRef = _firestore.collection('users').doc(githubId);
      final userSnap = await userRef.get();

      // 3) Auto-create OR update user document
      if (!userSnap.exists) {
        await userRef.set({
          'uid': githubId,
          'username': username,
          'avatarUrl': avatarUrl,
          'email': email,
          'lastSeen': FieldValue.serverTimestamp(),
          'settings': {
            'commitsPerRun': 10,
            'includePrivate': true,
            'templateId': 'default',
          },
          'dailyCounters': {},
        });
      } else {
        await userRef.update({
          'username': username,
          'avatarUrl': avatarUrl,
          'email': email,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      // 4) Store token locally
      await _secureStorage.write(
        key: 'github_access_token',
        value: accessToken,
      );
      await _secureStorage.write(
        key: 'github_user_id',
        value: githubId,
      );

      return const LoginResult(success: true);
    } catch (e) {
      // You can log e if you want more detail while debugging
      return const LoginResult(
        success: false,
        errorMessage: 'Login failed. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'github_access_token');
    await _secureStorage.delete(key: 'github_user_id');
  }

  Future<bool> hasValidSession() async {
    final token = await _secureStorage.read(key: 'github_access_token');
    final uid = await _secureStorage.read(key: 'github_user_id');
    return token != null && uid != null;
  }
}
