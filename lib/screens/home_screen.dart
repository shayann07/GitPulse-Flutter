import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/run_history_entry.dart';
import '../models/today_stats.dart';
import '../providers/app_providers.dart';
import 'history_screen.dart';
import 'repositories_screen.dart';
import 'run_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final reposAsync = ref.watch(reposProvider);
    final statsAsync = ref.watch(todayStatsProvider);
    final settingsAsync = ref.watch(userSettingsProvider);
    final historyAsync = ref.watch(runHistoryProvider);

    final username = userAsync.when(
      data: (user) => user?.username ?? 'GitHub user',
      loading: () => 'Loading...',
      error: (_, __) => 'GitHub user',
    );

    final repoCount = reposAsync.when(
      data: (repos) => repos.length.toString(),
      loading: () => '...',
      error: (_, __) => '--',
    );

    final todayCommits = statsAsync.when(
      data: (TodayStats stats) => stats.totalCommits.toString(),
      loading: () => '...',
      error: (_, __) => '--',
    );

    final successRate = statsAsync.when(
      data: (TodayStats stats) =>
          '${stats.successRate.isNaN ? 0 : stats.successRate.round()}%',
      loading: () => '...',
      error: (_, __) => '--',
    );

    // ===== DYNAMIC "X Repositories Selected" CHIP TEXT =====
    final selectedLabel = reposAsync.when(
      data: (repos) {
        final settings = settingsAsync.asData?.value;
        final includePrivateFlag = settings?.includePrivate ?? true;

        int selectedCount = 0;

        for (final repo in repos) {
          final key = repo.fullName;
          bool selected;

          if (settings != null && settings.repoSelections.containsKey(key)) {
            // explicit user choice from Firestore
            selected = settings.repoSelections[key]!;
          } else {
            // default selection logic based on includePrivate
            selected = includePrivateFlag ? true : !repo.isPrivate;
          }

          if (selected) selectedCount++;
        }

        if (selectedCount == 1) {
          return '1 Repository Selected';
        }
        return '$selectedCount Repositories Selected';
      },
      loading: () => 'Loading...',
      error: (_, __) => 'Repositories Selected',
    );

    return Scaffold(
      backgroundColor: _GitPulseColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(username: username),
              const SizedBox(height: 26),
              _MainRunCard(selectedLabel: selectedLabel),
              const SizedBox(height: 22),
              _MetricRow(
                repoCount: repoCount,
                todayCommits: todayCommits,
                successRate: successRate,
                statsAsync: statsAsync,
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Quick Action'),
              const SizedBox(height: 12),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 26),
              const _SectionTitle('Recent Activities'),
              const SizedBox(height: 14),
              _RecentActivityCard(
                historyAsync: historyAsync,
                statsAsync: statsAsync,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== HEADER =====================

class _Header extends StatelessWidget {
  final String username;

  const _Header({required this.username});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
        Transform.translate(
          offset: const Offset(-3, -1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "GitPulse",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '@$username',
                style: const TextStyle(
                  color: Color(0xFFB4B4C0),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
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

class _MainRunCard extends StatelessWidget {
  final String selectedLabel;

  const _MainRunCard({required this.selectedLabel});

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
                  Text(
                    selectedLabel,
                    style: const TextStyle(
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

Color usageDot(double ratio) {
  if (ratio >= 0.90) return Colors.redAccent;
  if (ratio >= 0.50) return Colors.yellowAccent;
  return Colors.greenAccent;
}

class _MetricRow extends StatelessWidget {
  final String repoCount;
  final String todayCommits;
  final String successRate;
  final AsyncValue<TodayStats> statsAsync;

  const _MetricRow({
    required this.repoCount,
    required this.todayCommits,
    required this.successRate,
    required this.statsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            iconAsset: 'assets/repo_icon.svg',
            value: repoCount,
            label: 'Repositories',
          ),
        ),
        const SizedBox(width: 10),
        // TODAY – special long-press behaviour
        Expanded(
          child: _TodayMetricCard(value: todayCommits, statsAsync: statsAsync),
        ),

        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            iconAsset: 'assets/success_icon.svg',
            value: successRate,
            label: 'Success',
          ),
        ),
      ],
    );
  }
}

class _TodayMetricCard extends StatefulWidget {
  final String value;
  final AsyncValue<TodayStats> statsAsync;
  static const int maxDaily = 500;

  const _TodayMetricCard({required this.value, required this.statsAsync});

  @override
  State<_TodayMetricCard> createState() => _TodayMetricCardState();
}

class _TodayMetricCardState extends State<_TodayMetricCard> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showOverlay(context),
      child: widget.statsAsync.when(
        data: (stats) {
          final ratio = stats.totalCommits / _TodayMetricCard.maxDaily;
          return _MetricCard(
            iconAsset: 'assets/today_icon.svg',
            value: widget.value,
            label: 'Today',
            ratio: ratio, // dot appears next to number only
          );
        },
        loading: () => _MetricCard(
          iconAsset: 'assets/today_icon.svg',
          value: widget.value,
          label: 'Today',
        ),
        error: (_, __) => _MetricCard(
          iconAsset: 'assets/today_icon.svg',
          value: widget.value,
          label: 'Today',
        ),
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final cardOffset = renderBox.localToGlobal(Offset.zero);
    final cardSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return GestureDetector(
          onTap: _removeOverlay,
          child: Stack(
            children: [
              // === BLUR LAYER ===
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black38),
                ),
              ),

              // === EXPANDED CARD (NOT LOCKED TO ORIGINAL HEIGHT) ===
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: (MediaQuery.of(context).size.width * 0.075),
                // center horizontally
                top: cardOffset.dy - 20,
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: Material(
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width * 0.85,
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                      ),
                      child: _ExpandedTodayCard(statsAsync: widget.statsAsync),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context, debugRequiredFor: widget)?.insert(_overlayEntry!);
  }
}

class _ExpandedTodayCard extends StatelessWidget {
  final AsyncValue<TodayStats> statsAsync;
  static const int maxDaily = 500;

  const _ExpandedTodayCard({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    return statsAsync.when(
      loading: () => _build(context, 0, "… / 500 commits", 0, "Loading..."),
      error: (_, __) => _build(context, 0, "Error", 0, ""),
      data: (stats) {
        final used = stats.totalCommits;
        final ratio = used / maxDaily;
        final commits = "$used / $maxDaily commits";
        final reset = _resetTime();
        return _build(context, used, commits, ratio, reset);
      },
    );
  }

  Widget _build(
    BuildContext context,
    int value,
    String commits,
    double ratio,
    String reset,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _GitPulseColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ICON + TODAY + DOT
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _GitPulseColors.metricIconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset('assets/today_icon.svg'),
              ),
              const SizedBox(width: 12),

              // "Today" + dot
              Row(
                children: [
                  const Text(
                    "Today",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: usageDot(ratio),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // progress bar
          _LimitProgressBar(progress: ratio),

          const SizedBox(height: 16),

          Text(
            commits,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 6),

          Text(
            "Resets in $reset",
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _resetTime() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final d = midnight.difference(now);
    if (d.inHours == 0) return "${d.inMinutes}m";
    return "${d.inHours}h ${d.inMinutes % 60}m";
  }
}

class _TodayLimitPopup extends StatelessWidget {
  final AsyncValue<TodayStats> statsAsync;
  static const int maxDaily = 500;

  const _TodayLimitPopup({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    return statsAsync.when(
      loading: () => _buildCard(
        context,
        title: 'Today’s Limit',
        subtitle: 'Loading...',
        progress: 0,
      ),
      error: (_, __) => _buildCard(
        context,
        title: 'Today’s Limit',
        subtitle: 'Unable to load stats',
        progress: 0,
      ),
      data: (stats) {
        final used = stats.totalCommits;
        final clamped = used.clamp(0, maxDaily);
        final ratio = maxDaily == 0 ? 0.0 : clamped / maxDaily;
        final subtitle = '$used / $maxDaily commits';

        return _buildCard(
          context,
          title: 'Today’s Limit',
          subtitle: subtitle,
          progress: ratio,
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double progress,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: _GitPulseColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: icon + title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _GitPulseColors.inner,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(9),
                child: SvgPicture.asset(
                  'assets/today_icon.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          _LimitProgressBar(progress: progress),

          const SizedBox(height: 8),
          const Text(
            'Long-pressed on Today',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LimitProgressBar extends StatelessWidget {
  final double progress;

  const _LimitProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E26),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth * clamped;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB74A), Color(0xFFFF6A00)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String iconAsset;
  final String value;
  final String label;
  final double? ratio; // null = no dot

  const _MetricCard({
    required this.iconAsset,
    required this.value,
    required this.label,
    this.ratio,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ICON ONLY
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _GitPulseColors.metricIconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(iconAsset),
          ),

          const SizedBox(height: 12),

          // VALUE + DOT
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (ratio != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: usageDot(ratio!),
                    shape: BoxShape.circle,
                  ),
                ),
              ]
            ],
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
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
        borderRadius: BorderRadius.circular(18),
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
  final AsyncValue<List<RunHistoryEntry>> historyAsync;
  final AsyncValue<TodayStats> statsAsync;

  const _RecentActivityCard({
    required this.historyAsync,
    required this.statsAsync,
  });

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
        children: [
          // ==========================
          // ROW 1: Successful Summary
          // ==========================
          _buildSuccessRow(context),

          const SizedBox(height: 14),
          const Divider(height: 1, color: _GitPulseColors.divider),
          const SizedBox(height: 14),

          // ==========================
          // ROW 2: Scheduled (static)
          // ==========================
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scheduled runs are not supported yet.'),
                ),
              );
            },
            child: const _RecentActivityItem(
              iconAsset: 'assets/run_schedule.svg',
              title: 'Run Scheduled',
              detail: '3 Repositories • 15m ago',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRow(BuildContext context) {
    return historyAsync.when(
      loading: () => const _RecentActivityLoading(),
      error: (_, __) =>
          const _RecentActivityEmpty(message: 'Could not load activity.'),
      data: (history) {
        return statsAsync.when(
          loading: () => const _RecentActivityLoading(),
          error: (_, __) =>
              const _RecentActivityEmpty(message: 'Could not load activity.'),
          data: (stats) {
            final successful = history
                .where((e) => e.success && e.markersAdded > 0)
                .toList();

            if (successful.isEmpty) {
              return const _RecentActivityItem(
                iconAsset: 'assets/run_completed_icon.svg',
                title: 'Run Completed Successfully',
                detail: 'No successful runs today',
              );
            }

            // total from stats:
            final repoCount = stats.successfulSessions;
            final commitsToday = stats.totalCommits;

            // latest successful entry:
            successful.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            final latest = successful.first;

            final timeAgo = _formatRelativeTime(latest.timestamp);

            final detail =
                '$repoCount Repositories • $commitsToday commits • $timeAgo';

            return _RecentActivityItem(
              iconAsset: 'assets/run_completed_icon.svg',
              title: 'Run Completed Successfully',
              detail: detail,
            );
          },
        );
      },
    );
  }
}

String _formatRelativeTime(DateTime timestamp) {
  final now = DateTime.now();
  final localTs = timestamp.toLocal();
  final diff = now.difference(localTs);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
}

class _RecentActivityLoading extends StatelessWidget {
  const _RecentActivityLoading();

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
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 12,
                width: 140,
                decoration: BoxDecoration(
                  color: _GitPulseColors.inner,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                width: 200,
                decoration: BoxDecoration(
                  color: _GitPulseColors.inner,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentActivityEmpty extends StatelessWidget {
  final String message;

  const _RecentActivityEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: Color(0xFF8D8D95),
        fontSize: 12,
        height: 1.4,
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
                  color: Color(0xFFE2E2E9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: const TextStyle(color: Color(0xFF8D8D95), fontSize: 12),
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
