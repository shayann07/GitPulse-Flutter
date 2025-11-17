import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'login_screen.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<WalkItem> items = [
    WalkItem(
      image: "assets/walk1.svg",
      title: "Keep your GitHub streak alive",
      subtitle:
          "Never lose your daily activity — even when you're away from your PC",
    ),
    WalkItem(
      image: "assets/walk2.svg",
      title: "Automate harmless commits",
      subtitle:
          "GitPulse adds safe marker commits to your repos — fully under your control",
    ),
    WalkItem(
      image: "assets/walk3.svg",
      title: "Secure GitHub login",
      subtitle:
          "Your token is encrypted locally. Nothing leaves your device without your control",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Skip Button ---
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (currentPage != items.length - 1) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: const [
                          Text(
                            "Skip",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ] else
                    const SizedBox(height: 20), // empty space on last page
                ],
              ),
            ),

            // --- PageView ---
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (_, i) => WalkPage(item: items[i]),
              ),
            ),

            const SizedBox(height: 6),

            // --- Dot indicators ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == i
                        ? const Color(0xFF9A61F8)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Next Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () {
                  if (currentPage < items.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9A61F8), Color(0xFF5B5EDB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    currentPage == items.length - 1 ? "Continue" : "Next",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class WalkPage extends StatelessWidget {
  final WalkItem item;

  const WalkPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration (SVG)
        SizedBox(
          height: 190,
          child: SvgPicture.asset(item.image, fit: BoxFit.contain),
        ),

        const SizedBox(height: 24),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// Simple model
class WalkItem {
  final String image;
  final String title;
  final String subtitle;

  WalkItem({required this.image, required this.title, required this.subtitle});
}
