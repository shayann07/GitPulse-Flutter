import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _autoRunEnabled = false;
  bool _darkModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SettingsColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SettingsHeader(),
              const SizedBox(height: 24),

              // ===== ACCOUNT SECTION =====
              const _SectionTitle('Account'),
              const SizedBox(height: 12),
              const _AccountCard(),
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
                    _PreferenceTile(
                      iconAsset: 'assets/notifications_icon.svg',
                      title: 'Notification',
                      subtitle: 'Get run updates',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                    const _SettingsDivider(),
                    _PreferenceTile(
                      iconAsset: 'assets/autorun_icon.svg',
                      title: 'Auto Run',
                      subtitle: 'Schedule automatic runs',
                      value: _autoRunEnabled,
                      onChanged: (value) {
                        setState(() => _autoRunEnabled = value);
                      },
                    ),
                    const _SettingsDivider(),
                    _PreferenceTile(
                      iconAsset: 'assets/dark_mode_icon.svg',
                      title: 'Dark Mode',
                      subtitle: 'Always enabled',
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() => _darkModeEnabled = value);
                      },
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

              const _AboutCard(),
              const SizedBox(height: 12),

              const _SettingsActionCard(
                title: 'Term & Privacy',
              ),

              const SizedBox(height: 32),

              _LogoutButton(
                onPressed: () {
                  // TODO: wire up real logout + token clearing
                },
              ),
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
  const _AccountCard();

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
          // same idea as home screen: clip + scale, no extra layout around svg
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
            children: const [
              Text(
                '@shayan-dev',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Connected via GitHub',
                style: TextStyle(
                  color: Color(0xFF9FA3A1),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          SvgPicture.asset(
            'assets/arrow_right.svg',
            width: 14,
            height: 14,
          ),
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
            child: SvgPicture.asset(
              iconAsset,
              fit: BoxFit.contain,
            ),
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
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85, // smaller toggle
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
                child: SvgPicture.asset(
                  iconAsset!,
                  fit: BoxFit.contain,
                ),
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
            SvgPicture.asset(
              'assets/arrow_right.svg',
              width: 14,
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== ABOUT CARD =====================

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _SettingsColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: const [
          _AboutRow(label: 'Version', value: '1.0.0'),
          SizedBox(height: 8),
          _AboutRow(label: 'Build', value: '2025.11'),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFB4B4C0),
            fontSize: 13,
          ),
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
          border: Border.all(
            color: const Color(0xFFFF4B4B),
            width: 1.4,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/logout_icon.svg',
              width: 18,
              height: 18,
            ),
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

  static const Color iconBg = Color(0xFF21212F); // icon container color
  static const Color accent = Color(0xFF7F56D9);
  static const Color divider = Color.fromARGB(40, 255, 255, 255);

  static const Color backButtonBackground = Color(0xFF1A1A1A);
}
