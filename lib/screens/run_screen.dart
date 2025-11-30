import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/app_providers.dart';
import '../services/run_service.dart';
import 'history_screen.dart';

class RunScreen extends ConsumerStatefulWidget {
  const RunScreen({super.key});

  @override
  ConsumerState<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends ConsumerState<RunScreen> {
  bool _isRunning = false;
  bool _hasCompleted = false;
  double _progress = 0.0; // 0.0 - 1.0
  String _statusLabel = 'Preparing run...';

  String? _repoName;
  int _markersRequested = 0;
  int _markersAdded = 0;
  String? _errorMessage;

  Timer? _fakeProgressTimer;

  @override
  void initState() {
    super.initState();
    // Kick off the run when we land on this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRun();
    });
  }

  @override
  void dispose() {
    _fakeProgressTimer?.cancel();
    super.dispose();
  }

  void _startFakeProgress() {
    _fakeProgressTimer?.cancel();
    _fakeProgressTimer = Timer.periodic(const Duration(milliseconds: 150), (
      timer,
    ) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      setState(() {
        const maxWhileRunning = 0.85;
        if (_progress < maxWhileRunning) {
          _progress = (_progress + 0.02).clamp(0.0, maxWhileRunning);
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _startRun() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _hasCompleted = false;
      _progress = 0.0;
      _statusLabel = 'Running';
      _errorMessage = null;
      _repoName = null;
      _markersAdded = 0;
      _markersRequested = 0;
    });

    _startFakeProgress();

    try {
      final session = await ref.read(sessionProvider.future);
      if (session == null) {
        throw Exception('Not logged in with GitHub');
      }

      final settings = await ref.read(userSettingsProvider.future);
      final repos = await ref.read(reposProvider.future);

      _markersRequested = settings.commitsPerRun;

      final result = await RunService.instance.runNow(
        session: session,
        settings: settings,
        allRepos: repos,
      );

      if (!mounted) return;

      setState(() {
        _isRunning = false;
        _hasCompleted = true;
        _progress = 1.0;

        _repoName = result.repo.fullName;
        _markersAdded = result.markersAdded;
        _errorMessage = result.errorMessage;

        if (result.success) {
          _statusLabel = 'Completed';
        } else if (result.markersAdded > 0) {
          _statusLabel = 'Completed with issues';
        } else {
          _statusLabel = 'Failed';
        }
      });

      // Refresh stats & history on Home after a run.
      ref.invalidate(todayStatsProvider);
      ref.invalidate(runHistoryProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRunning = false;
        _hasCompleted = true;
        _progress = 1.0;
        _statusLabel = 'Failed';
        _errorMessage = e.toString();
      });
    } finally {
      _fakeProgressTimer?.cancel();
    }
  }

  void _handleBack(BuildContext context) {
    if (_isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Run in progress, please wait for it to finish.'),
        ),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  void _handlePause() {
    // Not implementing real pause in MVP – just surface a message.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pause is not supported in this version.')),
    );
  }

  void _handleCancel() {
    // Same story as pause – we commit sequentially and can’t safely cancel mid-flight yet.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cancel is not supported in this version.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = _progress.clamp(0.0, 1.0);
    final displayPercent = (percent * 100).round();

    return Scaffold(
      backgroundColor: _GPColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopControls(
                isRunning: _isRunning,
                onBack: () => _handleBack(context),
                onPause: _handlePause,
                onCancel: _handleCancel,
              ),
              const SizedBox(height: 26),
              _ProgressCard(
                percent: percent,
                displayPercent: displayPercent,
                statusLabel: _statusLabel,
              ),
              const SizedBox(height: 26),
              const _SectionTitle('Repositories Progress'),
              const SizedBox(height: 16),
              _buildRepoProgressSection(),
              const SizedBox(height: 32),
              const _ViewHistoryButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepoProgressSection() {
    if (_isRunning) {
      return _RepoInProgressCard(
        name: 'Running on selected repo…',
        subtitle: 'Applying automated commits...',
        percent: (_progress * 100).round().clamp(0, 100),
      );
    }

    if (!_hasCompleted || _repoName == null) {
      return const _RepoPendingCard(name: 'Waiting for run to start');
    }

    // Completed state
    if (_errorMessage == null && _markersAdded > 0) {
      final subtitle = _markersAdded == _markersRequested
          ? 'Committed $_markersAdded markers'
          : 'Committed $_markersAdded of $_markersRequested markers';
      return _RepoSuccessCard(name: _repoName!, subtitle: subtitle);
    }

    if (_markersAdded > 0) {
      final subtitle =
          'Committed $_markersAdded of $_markersRequested markers (partial)';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RepoSuccessCard(name: _repoName!, subtitle: subtitle),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFFF7A7A), fontSize: 12),
            ),
          ],
        ],
      );
    }

    // Failed completely
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RepoPendingCard(name: _repoName ?? 'Selected repository'),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Color(0xFFFF7A7A), fontSize: 12),
          ),
        ],
      ],
    );
  }
}

//
// ===================== TOP CONTROLS =====================
//

class _TopControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onBack;
  final VoidCallback onPause;
  final VoidCallback onCancel;

  const _TopControls({
    required this.isRunning,
    required this.onBack,
    required this.onPause,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ControlButton(icon: 'assets/arrow_left.svg', onTap: onBack),
        Row(
          children: [
            _ControlButton(
              icon: 'assets/pause_icon.svg',
              onTap: isRunning ? onPause : null,
            ),
            const SizedBox(width: 10),
            _ControlButton(
              icon: 'assets/cross_icon.svg',
              onTap: isRunning ? onCancel : onBack,
            ),
          ],
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;

  const _ControlButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1E),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(icon, width: 16, height: 16),
        ),
      ),
    );
  }
}

//
// ===================== MAIN PROGRESS CARD =====================
//

class _ProgressCard extends StatelessWidget {
  final double percent;
  final int displayPercent;
  final String statusLabel;

  const _ProgressCard({
    required this.percent,
    required this.displayPercent,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF15151A),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$displayPercent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusLabel,
            style: const TextStyle(color: Color(0xFFC4C4CE), fontSize: 15),
          ),
          const SizedBox(height: 22),
          _MainGradientProgressBar(percent: percent),
        ],
      ),
    );
  }
}

class _MainGradientProgressBar extends StatelessWidget {
  final double percent;

  const _MainGradientProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF282830),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * clamped;

          return Container(
            width: width,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6A00), Color(0xFFCA00FF)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

//
// ===================== SUCCESS CARD =====================
//

class _RepoSuccessCard extends StatelessWidget {
  final String name;
  final String subtitle;

  const _RepoSuccessCard({required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF07120D),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0B1A13),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(6),
            child: SvgPicture.asset(
              'assets/check_icon.svg',
              width: 14,
              height: 14,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF34E07A), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
// ===================== IN-PROGRESS CARD =====================
//

class _RepoInProgressCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final int percent;

  const _RepoInProgressCard({
    required this.name,
    required this.subtitle,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF15151A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D23),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  'assets/pause_icon.svg',
                  width: 15,
                  height: 15,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8E8E96),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$clampedPercent%',
                style: const TextStyle(color: Color(0xFFC2C3CC), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RepoProgressBar(percent: clampedPercent / 100),
        ],
      ),
    );
  }
}

class _RepoProgressBar extends StatelessWidget {
  final double percent;

  const _RepoProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF20202A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * clamped;

          return Container(
            width: width,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A5CFF), Color(0xFFB06BFF)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

//
// ===================== PENDING CARD =====================
//

class _RepoPendingCard extends StatelessWidget {
  final String name;

  const _RepoPendingCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF15151A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1D1D23),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF61616A), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

//
// ===================== SECTION TITLE =====================
//

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF9E9EAA),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

//
// ===================== VIEW HISTORY BUTTON =====================
//

class _ViewHistoryButton extends StatelessWidget {
  const _ViewHistoryButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A5CFF), Color(0xFFB06BFF)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text(
            'View History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

//
// ===================== DESIGN TOKENS =====================
//

class _GPColors {
  static const Color background = Color(0xFF0A0A0D);
}
