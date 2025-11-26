import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/auth_service.dart';
import '../firebase_options.dart';
import 'home_screen.dart';
import 'walkthrough_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: GitPulseApp()));
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

/// Splash now checks if there is a valid GitHub session.
/// If yes → goes straight to HomeScreen, otherwise WalkthroughScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // keep your splash delay
    await Future.delayed(const Duration(seconds: 2));

    final hasSession = await AuthService.instance.hasValidSession();

    if (!mounted) return;

    if (hasSession) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(flex: 3),
              SizedBox(
                width: 200,
                height: 200,
                child: SvgPicture.asset(
                  'assets/gitpulse_logo.svg',
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
