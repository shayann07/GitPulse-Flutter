import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gitpulse/walkthrough_screen.dart';

void main() {
  runApp(const GitPulseApp());
}

class GitPulseApp extends StatelessWidget {
  const GitPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitPulse',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
      );
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(flex: 3),

              // LOGO — NO glow, no shadow, just pure SVG
              SizedBox(
                width: 200,
                height: 200,
                child: SvgPicture.asset(
                  'assets/gitpulse_logo.svg', // your glow is inside SVG
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),

              const Text(
                'GitPulse',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Automated GitHub Commit Markers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.2,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
