import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // ==== BIGGER LOGO ====
                      SizedBox(
                        width: 145,
                        height: 145,
                        child: SvgPicture.asset("assets/gitpulse_logo.svg"),
                      ),

                      // ==== TITLE ====
                      const Text(
                        "Sign in to your\nAccount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ==== INPUT FIELDS ====
                      InputField(
                        hint: "Username or Email",
                        icon: "assets/ic_email.svg",
                      ),

                      const SizedBox(height: 16),

                      InputField(
                        hint: "Password",
                        icon: "assets/ic_password.svg",
                        isPassword: true,
                        obscurePassword: obscurePassword,
                        onEyeTap: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                      ),

                      const SizedBox(height: 28),

                      // ==== LOGIN BUTTON ====
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 54,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFA961FB), Color(0xFF5B5EDB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==== GOOGLE BUTTON (WITH GLOW) ====
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFA961FB), Color(0xFF4285F4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF9A61F8,
                                ).withOpacity(0.35),
                                blurRadius: 20,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF120F1A),
                                  // subtle purple-black blend
                                  Color(0xFF050509),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/ic_google.svg",
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // ==== FOOTER FIXED AT BOTTOM ====
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                children: [
                  const Text(
                    "By continuing, you agree to our",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 4),

                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Terms of Service",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: " and ",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// INPUT FIELD — Fixed colors, radius, icon size, hint visibility
// ===========================================================

class InputField extends StatelessWidget {
  final String hint;
  final String icon;
  final bool isPassword;
  final bool obscurePassword;
  final VoidCallback? onEyeTap;

  const InputField({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.obscurePassword = false,
    this.onEyeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1F), // closer to Figma
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 16, // smaller icon
            height: 16,
          ),
          const SizedBox(width: 12),

          // TEXT FIELD + VISIBLE HINT
          Expanded(
            child: TextField(
              obscureText: isPassword ? obscurePassword : false,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Colors.white38,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),

          // PASSWORD EYE ICON
          if (isPassword)
            GestureDetector(
              onTap: onEyeTap,
              child: const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: Colors.white38,
              ),
            ),
        ],
      ),
    );
  }
}
