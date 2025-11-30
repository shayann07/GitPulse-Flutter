import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gitpulse/providers/app_providers.dart';
import 'package:gitpulse/services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'walkthrough_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _uid;
  String _username = '';

  bool _includePrivate = true;
  int _commitsPerRun = 10;

  String _appVersion = '1.0.0';
  String _buildLabel = '';

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final uid = await _secureStorage.read(key: 'github_user_id');
      _uid = uid;

      if (uid != null) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final data = userDoc.data();

        if (data != null) {
          _username = (data['username'] ?? '') as String;

          final settings =
              (data['settings'] as Map<String, dynamic>?) ??
              <String, dynamic>{};
          _includePrivate = settings['includePrivate'] as bool? ?? true;
          _commitsPerRun = settings['commitsPerRun'] as int? ?? 10;
        }
      }

      try {
        final info = await PackageInfo.fromPlatform();
        _appVersion = info.version;
      } catch (_) {
        // ignore, keep default
      }

      final now = DateTime.now();
      _buildLabel = '${now.year}.${now.month.toString().padLeft(2, '0')}';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _updateIncludePrivate(bool value) async {
    setState(() => _includePrivate = value);

    if (_uid == null) return;

    await _firestore.collection('users').doc(_uid).set({
      'settings': {'includePrivate': value},
    }, SetOptions(merge: true));

    // force Riverpod to reload settings everywhere (Home, Repos, etc.)
    ref.invalidate(userSettingsProvider);
    ref.invalidate(reposProvider);
  }

  Future<void> _updateCommitsPerRun(int value) async {
    if (value < 1) value = 1;
    if (value > 500) value = 500;

    setState(() => _commitsPerRun = value);

    if (_uid == null) return;

    await _firestore.collection('users').doc(_uid).set({
      'settings': {'commitsPerRun': value},
    }, SetOptions(merge: true));

    // also refresh settings provider
    ref.invalidate(userSettingsProvider);
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.instance.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SettingsColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SettingsHeader(),
                    const SizedBox(height: 24),

                    // ===== ACCOUNT SECTION =====
                    const _SectionTitle('Account'),
                    const SizedBox(height: 12),
                    _AccountCard(username: _username),
                    const SizedBox(height: 24),

                    // ===== PREFERENCES SECTION =====
                    const _SectionTitle('Preferences'),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: _SettingsColors.card,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          // Notification (hardcoded OFF, non-functional)
                          _PreferenceTile(
                            iconAsset: 'assets/notifications_icon.svg',
                            title: 'Notification',
                            subtitle: 'Get run updates',
                            value: false,
                            onChanged: (_) {},
                          ),
                          const _SettingsDivider(),

                          // Auto Run (hardcoded OFF, non-functional)
                          _PreferenceTile(
                            iconAsset: 'assets/autorun_icon.svg',
                            title: 'Auto Run',
                            subtitle: 'Schedule automatic runs',
                            value: false,
                            onChanged: (_) {},
                          ),
                          const _SettingsDivider(),

                          // Dark mode (always enabled, cannot be turned off)
                          _PreferenceTile(
                            iconAsset: 'assets/dark_mode_icon.svg',
                            title: 'Dark Mode',
                            subtitle: 'Always enabled',
                            value: true,
                            onChanged: (_) {},
                          ),
                          const _SettingsDivider(),

                          // Include private repos (Firestore-backed)
                          _PreferenceTile(
                            iconAsset: 'assets/privacy_icon.svg',
                            title: 'Include private repos',
                            subtitle: 'Use private repos when running',
                            value: _includePrivate,
                            onChanged: _updateIncludePrivate,
                          ),
                          const _SettingsDivider(),

                          // Commits per run stepper
                          _CommitsPerRunRow(
                            value: _commitsPerRun,
                            onDecrement: () =>
                                _updateCommitsPerRun(_commitsPerRun - 1),
                            onIncrement: () =>
                                _updateCommitsPerRun(_commitsPerRun + 1),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== PRIVACY SECTION =====
                    const _SectionTitle('Privacy'),
                    const SizedBox(height: 12),

                    const _SettingsActionCard(
                      iconAsset: 'assets/privacy_icon.svg',
                      title: 'Privacy & Permission',
                      subtitle: 'Manage app access',
                    ),

                    const SizedBox(height: 24),

                    // ===== ABOUT SECTION =====
                    const _SectionTitle('About'),
                    const SizedBox(height: 12),

                    _AboutCard(version: _appVersion, buildLabel: _buildLabel),
                    const SizedBox(height: 12),

                    const _SettingsActionCard(title: 'Term & Privacy'),

                    const SizedBox(height: 32),

                    _LogoutButton(onPressed: () => _handleLogout(context)),
                  ],
                ),
              ),
      ),
    );
  }
}

// ===================== HEADER =====================

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _SettingsColors.backButtonBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/arrow_left.svg',
              width: 16,
              height: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Preferences & account',
              style: TextStyle(
                color: Color(0xFF9FA3A1),
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ===================== SECTION TITLE =====================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ===================== ACCOUNT CARD =====================

class _AccountCard extends StatelessWidget {
  final String username;

  const _AccountCard({required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _SettingsColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Transform.translate(
            offset: const Offset(-2, 0),
            child: Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Transform.scale(
                scale: 1.35,
                child: SvgPicture.asset('assets/gitpulse_logo.svg'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@$username',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Connected via GitHub',
                style: TextStyle(color: Color(0xFF9FA3A1), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          // Arrow removed – no navigation from this card anymore.
        ],
      ),
    );
  }
}

// ===================== PREFERENCE TILE =====================

class _PreferenceTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _SettingsColors.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(9),
            child: SvgPicture.asset(iconAsset, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: _SettingsColors.accent,
              inactiveTrackColor: const Color(0xFF2C2C33),
            ),
          ),
        ],
      ),
    );
  }
}

// Divider inside cards (indented a bit)
class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: _SettingsColors.divider,
    );
  }
}

// ===================== COMMITS PER RUN ROW =====================

class _CommitsPerRunRow extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CommitsPerRunRow({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _SettingsColors.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Commits per run',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Number of commits each run',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircleIconButton(icon: Icons.remove_rounded, onTap: onDecrement),
              const SizedBox(width: 10),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              _CircleIconButton(icon: Icons.add_rounded, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF272735),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

// ===================== SIMPLE ACTION CARD =====================

class _SettingsActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? iconAsset;
  final VoidCallback? onTap;

  const _SettingsActionCard({
    this.iconAsset,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _SettingsColors.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            if (iconAsset != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _SettingsColors.iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(iconAsset!, fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SvgPicture.asset('assets/arrow_right.svg', width: 14, height: 14),
          ],
        ),
      ),
    );
  }
}

// ===================== ABOUT CARD =====================

class _AboutCard extends StatelessWidget {
  final String version;
  final String buildLabel; // renamed from "build"

  const _AboutCard({required this.version, required this.buildLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _SettingsColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _AboutRow(label: 'Version', value: version),
          const SizedBox(height: 8),
          _AboutRow(label: 'Build', value: buildLabel),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Color(0xFFB4B4C0), fontSize: 13),
        ),
      ],
    );
  }
}

// ===================== LOGOUT BUTTON =====================

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF2B0E11),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFF4B4B), width: 1.4),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/logout_icon.svg', width: 18, height: 18),
            const SizedBox(width: 8),
            const Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFFF4B4B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== DESIGN TOKENS =====================

class _SettingsColors {
  static const Color background = Color(0xFF0A0A0D);
  static const Color card = Color(0xFF131317);
  static const Color inner = Color(0xFF1E1E24);

  static const Color iconBg = Color(0xFF21212F);
  static const Color accent = Color(0xFF7F56D9);
  static const Color divider = Color.fromARGB(40, 255, 255, 255);

  static const Color backButtonBackground = Color(0xFF1A1A1A);
}
