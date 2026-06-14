import 'package:one_coorg/home_page.dart';
import 'package:one_coorg/screens/intro/intro_page_four.dart';
import 'package:one_coorg/screens/intro/intro_page_three.dart';
import 'package:one_coorg/screens/intro/intro_screen_one.dart';
import 'package:one_coorg/screens/intro/intro_screen_two.dart';
import 'package:one_coorg/services/preferences_service.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroPageController extends StatefulWidget {
  const IntroPageController({super.key});

  @override
  State<IntroPageController> createState() => _IntroPageControllerState();
}

class _IntroPageControllerState extends State<IntroPageController> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  bool get _isLastPage => _currentPage == _totalPages - 1;

  Future<void> _finishIntro() async {
    await PreferencesService.markIntroAsSeen();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ──────────────────────────────────
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isLastPage ? 0.0 : 1.0,
                    child: TextButton(
                      onPressed: _isLastPage ? null : _finishIntro,
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          color: AppColors.backgroundDark.withValues(
                            alpha: 0.45,
                          ),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView ─────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: const [
                  IntroScreenOne(),
                  IntroScreenTwo(),
                  IntroPageThree(),
                  IntroPageFour(),
                ],
              ),
            ),

            // ── Bottom bar: dots + next button ───────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Smooth page indicator dots
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _totalPages,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.backgroundDark,
                      dotColor: AppColors.backgroundDark.withValues(alpha: 0.2),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 6,
                    ),
                  ),

                  // Next / Get Started button
                  GestureDetector(
                    onTap: _isLastPage ? _finishIntro : _goToNextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 52,
                      width: _isLastPage ? 148 : 52,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.circular(
                          _isLastPage ? 16 : 50,
                        ),
                      ),
                      child: Center(
                        child: _isLastPage
                            ? const Text(
                                "Get Started",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
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
