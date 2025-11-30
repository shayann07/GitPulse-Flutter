import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/run_history_entry.dart';
import '../providers/app_providers.dart';

enum _HistoryFilter { all, success, failed }

enum _RunStatus { success, partial, failed }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _HistoryFilter _selected = _HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(runHistoryProvider);

    return Scaffold(
      backgroundColor: _HColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HistoryHeader(onBack: () => Navigator.of(context).pop()),
              const SizedBox(height: 24),
              _FilterRow(
                selected: _selected,
                onChanged: (value) {
                  setState(() => _selected = value);
                },
              ),
              const SizedBox(height: 28),
              Expanded(
                child: historyAsync.when(
                  data: (entries) => _buildHistoryList(context, entries),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text(
                      'Failed to load history\n$err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF9E9EAA),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<RunHistoryEntry> entries,
  ) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No runs yet.\nRun GitPulse to see your history here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF9E9EAA), fontSize: 13),
        ),
      );
    }

    // Apply filter.
    final filtered = entries.where((entry) {
      final status = _mapStatus(entry);
      switch (_selected) {
        case _HistoryFilter.all:
          return true;
        case _HistoryFilter.success:
          return status == _RunStatus.success;
        case _HistoryFilter.failed:
          return status == _RunStatus.failed || status == _RunStatus.partial;
      }
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'No runs match this filter.',
          style: TextStyle(color: Color(0xFF9E9EAA), fontSize: 13),
        ),
      );
    }

    final grouped = _groupByDay(filtered);

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: grouped.length,
      separatorBuilder: (_, __) => const SizedBox(height: 26),
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final label = entry.key;
        final runs = entry.value.map(_entryToRunCardData).toList();

        return _HistorySection(label: label, runs: runs);
      },
    );
  }

  Map<String, List<RunHistoryEntry>> _groupByDay(
    List<RunHistoryEntry> entries,
  ) {
    final map = <String, List<RunHistoryEntry>>{};
    for (final entry in entries) {
      final local = entry.timestamp.toLocal();
      final label = _groupLabelForDate(local);

      map.putIfAbsent(label, () => []).add(entry);
    }

    return map;
  }

  String _groupLabelForDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(thatDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthName = months[dt.month - 1];
    return '$monthName ${dt.day}';
  }

  _RunStatus _mapStatus(RunHistoryEntry entry) {
    if (entry.success && entry.markersAdded > 0) {
      return _RunStatus.success;
    }
    if (entry.isPartial) {
      return _RunStatus.partial;
    }
    return _RunStatus.failed;
  }

  _RunCardData _entryToRunCardData(RunHistoryEntry entry) {
    final status = _mapStatus(entry);
    final statusText = () {
      switch (status) {
        case _RunStatus.success:
          return 'Successful';
        case _RunStatus.partial:
          return 'Partial';
        case _RunStatus.failed:
          return 'Failed';
      }
    }();

    final local = entry.timestamp.toLocal();
    final timeText = _formatTime(local);

    final repoText = entry.fullName.isNotEmpty
        ? entry.fullName
        : '${entry.owner}/${entry.repoName}';
    final commitsText = '${entry.markersAdded} commits';

    return _RunCardData(
      status: status,
      statusText: statusText,
      time: timeText,
      reposText: repoText,
      commitsText: commitsText,
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final mm = minute.toString().padLeft(2, '0');
    return '$h12:$mm $suffix';
  }
}

//
// ===================== HEADER =====================
//

class _HistoryHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _HistoryHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1E),
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
              'History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Past runs and activity',
              style: TextStyle(color: Color(0xFF9E9EAA), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

//
// ===================== FILTER CHIPS =====================
//

class _FilterRow extends StatelessWidget {
  final _HistoryFilter selected;
  final ValueChanged<_HistoryFilter> onChanged;

  const _FilterRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'All Runs',
          isSelected: selected == _HistoryFilter.all,
          onTap: () => onChanged(_HistoryFilter.all),
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: 'Success',
          isSelected: selected == _HistoryFilter.success,
          onTap: () => onChanged(_HistoryFilter.success),
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: 'Failed',
          isSelected: selected == _HistoryFilter.failed,
          onTap: () => onChanged(_HistoryFilter.failed),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = isSelected
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A5CFF), Color(0xFFB06BFF)],
            ),
            borderRadius: BorderRadius.circular(20),
          )
        : BoxDecoration(
            color: const Color(0xFF2A2A33),
            borderRadius: BorderRadius.circular(20),
          );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: decoration,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

//
// ===================== SECTIONS =====================
//

class _HistorySection extends StatelessWidget {
  final String label;
  final List<_RunCardData> runs;

  const _HistorySection({required this.label, required this.runs});

  @override
  Widget build(BuildContext context) {
    if (runs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9E9EAA),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < runs.length; i++) ...[
          _RunCard(data: runs[i]),
          if (i != runs.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

//
// ===================== RUN CARD =====================
//

class _RunCardData {
  final _RunStatus status;
  final String statusText;
  final String time;
  final String reposText;
  final String commitsText;

  const _RunCardData({
    required this.status,
    required this.statusText,
    required this.time,
    required this.reposText,
    required this.commitsText,
  });
}

class _RunCard extends StatelessWidget {
  final _RunCardData data;

  const _RunCard({required this.data});

  @override
  Widget build(BuildContext context) {
    late Color cardColor;
    late Color iconBgColor;
    late Color statusColor;
    late String iconAsset;

    switch (data.status) {
      case _RunStatus.success:
        cardColor = const Color(0xFF07120D);
        iconBgColor = const Color(0xFF0B1A13);
        statusColor = const Color(0xFF34E07A);
        iconAsset = 'assets/check_icon.svg';
        break;
      case _RunStatus.partial:
        cardColor = const Color(0xFF120E07);
        iconBgColor = const Color(0xFF1F1508);
        statusColor = const Color(0xFFFFB74A);
        iconAsset = 'assets/partial_icon.svg';
        break;
      case _RunStatus.failed:
        cardColor = const Color(0xFF130808);
        iconBgColor = const Color(0xFF1F0C0C);
        statusColor = const Color(0xFFFF5B5B);
        iconAsset = 'assets/failed_icon.svg';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(6),
            child: SvgPicture.asset(iconAsset, width: 16, height: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '•',
                      style: TextStyle(color: Color(0xFF9E9EAA), fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.time,
                      style: const TextStyle(
                        color: Color(0xFFC4C4CE),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.reposText} • ${data.commitsText}',
                  style: const TextStyle(
                    color: Color(0xFF9E9EAA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset('assets/arrow_right.svg', width: 16, height: 16),
        ],
      ),
    );
  }
}

//
// ===================== COLORS =====================
//

class _HColors {
  static const Color background = Color(0xFF0A0A0D);
}
