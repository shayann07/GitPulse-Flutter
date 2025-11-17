import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RunScreen extends StatelessWidget {
  const RunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _GPColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _TopControls(),
              SizedBox(height: 26),
              _ProgressCard(),
              SizedBox(height: 26),
              _SectionTitle('Repositories Progress'),
              SizedBox(height: 16),

              // SUCCESS
              _RepoSuccessCard(
                name: 'GitPluse-android',
                subtitle: 'Committed 3 files',
              ),
              SizedBox(height: 12),
              _RepoSuccessCard(
                name: 'Dot Files',
                subtitle: 'Committed 2 file',
              ),

              SizedBox(height: 16),

              // IN PROGRESS
              _RepoInProgressCard(
                name: 'Website',
                subtitle: 'Committing changes ………. ',
                percent: 65,
              ),
              SizedBox(height: 16),
              _RepoInProgressCard(
                name: 'Analytics-Dashboard',
                subtitle: 'Processing files ………. ',
                percent: 35,
              ),

              SizedBox(height: 16),

              // PENDING
              _RepoPendingCard(name: 'Mobile - Lib'),
              SizedBox(height: 12),
              _RepoPendingCard(name: 'Api-server'),

              SizedBox(height: 32),
              _ViewHistoryButton(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ===================== TOP CONTROLS =====================
//

class _TopControls extends StatelessWidget {
  const _TopControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        // back on the left
        _ControlButton(icon: 'assets/arrow_left.svg'),

        // pause + close on the right
        Row(
          children: [
            _ControlButton(icon: 'assets/pause_icon.svg'),
            SizedBox(width: 10),
            _ControlButton(icon: 'assets/cross_icon.svg'),
          ],
        ),
      ],
    );
  }
}


class _ControlButton extends StatelessWidget {
  final String icon;
  const _ControlButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,          // smaller, closer to PNG
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        icon,
        width: 16,        // smaller icon
        height: 16,
      ),
    );
  }
}

//
// ===================== MAIN PROGRESS CARD =====================
//

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

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
        children: const [
          Text(
            '60%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Running',
            style: TextStyle(
              color: Color(0xFFC4C4CE),
              fontSize: 15,
            ),
          ),
          SizedBox(height: 22),
          _MainGradientProgressBar(percent: 0.60),
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
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF282830),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth * percent;

        return Container(
          width: width,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF6A00),
                Color(0xFFCA00FF),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

//
// ===================== SUCCESS CARD =====================
//

class _RepoSuccessCard extends StatelessWidget {
  final String name;
  final String subtitle;
  const _RepoSuccessCard({
    required this.name,
    required this.subtitle,
  });

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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0B1A13),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset('assets/check_icon.svg'),
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
                style: const TextStyle(
                  color: Color(0xFF34E07A),
                  fontSize: 12,
                ),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D23),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset('assets/pause_icon.svg'),
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
                '$percent%',
                style: const TextStyle(
                  color: Color(0xFFC2C3CC),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RepoProgressBar(percent: percent / 100),
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
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF20202A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth * percent;

        return Container(
          width: width,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6A5CFF),
                Color(0xFFB06BFF),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1D1D23),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF5F6068),
                    width: 2,
                  ),
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
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A5CFF),
            Color(0xFFB06BFF),
          ],
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
    );
  }
}

//
// ===================== DESIGN TOKENS =====================
//

class _GPColors {
  static const Color background = Color(0xFF0A0A0D);
}
