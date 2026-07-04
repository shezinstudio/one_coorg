import 'package:one_coorg/home_page.dart';
import 'package:one_coorg/screens/intro/intro_page_controller.dart';
import 'package:one_coorg/services/preferences_service.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // ── Animations ───────────────────────────────────────
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();

    // ── Navigate after delay ─────────────────────────────
    Future.delayed(const Duration(seconds: 3), () async {
      final hasSeenIntro = await PreferencesService.hasSeenIntro();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                hasSeenIntro ? const HomePage() : const IntroPageController(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient (themed) ────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary, // 0xFF2E7D32 – Deep Forest Green
                  Color(0xFF256427), // mid tone
                  Color(0xFF1B5E20), // darkest forest edge
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Subtle top vignette to add depth ────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.25),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // ── Centered logo + title ────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App logo
                    Image.asset(
                      "assets/images/logo_round.png",
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(height: 24),

                    // App name
                    Text(
                      "One Coorg",
                      style: TextStyle(
                        fontSize: 38,
                        color: AppColors.backgroundLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Divider accent
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Tourist Explore Guide",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.backgroundLight.withValues(
                              alpha: 0.85,
                            ),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 32,
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom loader + tagline ──────────────────────
          Positioned(
            bottom: 52,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 13,
                        color: AppColors.backgroundLight.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Discover the Scotland of India",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.backgroundLight.withValues(
                            alpha: 0.6,
                          ),
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
