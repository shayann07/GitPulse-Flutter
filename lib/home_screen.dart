import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gitpulse/repositories_screen.dart';
import 'package:gitpulse/run_screen.dart';
import 'package:gitpulse/settings_screen.dart';

import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _GitPulseColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              SizedBox(height: 26),
              _MainRunCard(),
              SizedBox(height: 22),
              _MetricRow(),
              SizedBox(height: 24),
              _SectionTitle('Quick Action'),
              SizedBox(height: 12),
              // ========= MANAGE REPOSITORIES =========
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RepositoriesScreen(),
                    ),
                  );
                },
                child: const _QuickActionTile(
                  iconAsset: 'assets/repo_icon.svg',
                  title: 'Manage repositories',
                  subtitle: 'Select & configure repositories',
                ),
              ),

              SizedBox(height: 10),

              // ========= VIEW HISTORY =========
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                child: const _QuickActionTile(
                  iconAsset: 'assets/history_icon.svg',
                  title: 'View History',
                  subtitle: 'Past runs & logs',
                ),
              ),

              SizedBox(height: 26),
              _SectionTitle('Recent Activities'),
              SizedBox(height: 14),
              _RecentActivityCard(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== HEADER =====================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ========== LOGO ==========
        Transform.translate(
          offset: const Offset(-3, 0),
          child: Container(
            width: 66,
            height: 66,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: Transform.scale(
              scale: 1.40,
              child: SvgPicture.asset("assets/gitpulse_logo.svg"),
            ),
          ),
        ),

        const SizedBox(width: 1),

        // ========== APP NAME + USERNAME ==========
        Transform.translate(
          offset: const Offset(-3, -1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "GitPulse",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "@shayan-dev",
                style: TextStyle(
                  color: Color(0xFFB4B4C0), // corrected
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // ========== SETTINGS ICON ==========
        Transform.translate(
          offset: const Offset(0, -1),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _GitPulseColors.inner,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/ic_gear.svg",
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== MAIN RUN CARD =====================

// ===================== MAIN RUN CARD =====================

class _MainRunCard extends StatelessWidget {
  const _MainRunCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: _GitPulseColors.card,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chip
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _GitPulseColors.inner,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _GitPulseColors.chipText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '6 Repositories Selected',
                    style: TextStyle(
                      color: _GitPulseColors.chipText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Play button
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RunScreen()),
                );
              },
              child: SvgPicture.asset(
                'assets/ic_play.svg',
                width: 120,
                height: 120,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Ready to Execute',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Run automated commits on selected repos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ===================== METRICS =====================

class _MetricRow extends StatelessWidget {
  const _MetricRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MetricCard(
            iconAsset: 'assets/repo_icon.svg',
            value: '24',
            label: 'Repositories',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            iconAsset: 'assets/today_icon.svg',
            value: '12',
            label: 'Today',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            iconAsset: 'assets/success_icon.svg',
            value: '98%',
            label: 'Success',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String iconAsset;
  final String value;
  final String label;

  const _MetricCard({
    required this.iconAsset,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _GitPulseColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // <-- IMPORTANT FIX
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _GitPulseColors.metricIconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(iconAsset, width: 20, height: 20),
          ),

          const SizedBox(height: 12), // nicer spacing

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
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

// ===================== QUICK ACTION TILES =====================

class _QuickActionTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;

  const _QuickActionTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _GitPulseColors.card,
        borderRadius: BorderRadius.circular(18), // corrected radius
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _GitPulseColors.inner,
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
          SvgPicture.asset('assets/arrow_right.svg', width: 18, height: 18),
        ],
      ),
    );
  }
}

// ===================== RECENT ACTIVITIES =====================

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _GitPulseColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: const [
          _RecentActivityItem(
            iconAsset: 'assets/run_completed_icon.svg',
            title: 'Run Completed Successfully',
            detail: '5 Repositories • 12 commits • 2m ago',
          ),
          SizedBox(height: 14),
          Divider(height: 1, color: _GitPulseColors.divider),
          SizedBox(height: 14),
          _RecentActivityItem(
            iconAsset: 'assets/run_schedule.svg',
            title: 'Run Scheduled',
            detail: '3 Repositories • 15m ago',
          ),
        ],
      ),
    );
  }
}

class _RecentActivityItem extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String detail;

  const _RecentActivityItem({
    required this.iconAsset,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _GitPulseColors.inner,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(9),
          child: SvgPicture.asset(iconAsset, fit: BoxFit.contain),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE2E2E9), // corrected
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: const TextStyle(
                  color: Color(0xFF8D8D95), // corrected
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===================== DESIGN TOKENS =====================

class _GitPulseColors {
  static const Color background = Color(0xFF0A0A0D);
  static const Color card = Color(0xFF131317);
  static const Color inner = Color(0xFF1E1E24);
  static const Color chipText = Color(0xFFA8A0FF);

  static const Color metricIconBg = Color(0xFF1A1A20);

  static const Color divider = Color.fromARGB(30, 255, 255, 255);
}
