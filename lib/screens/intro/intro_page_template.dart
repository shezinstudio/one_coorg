import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPageTemplate extends StatelessWidget {
  final String imagePath;
  final String eyebrow;
  final String title;
  final String description;

  const IntroPageTemplate({
    super.key,
    required this.imagePath,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double imageHeight = (screenHeight * 0.42).clamp(260.0, 360.0);

    return Column(
      children: [
        // ── Photo with ridge-line silhouette ───────────────
        ClipPath(
          clipper: _RidgeClipper(),
          child: Image.asset(
            imagePath,
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // ── Editorial text block ────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 4, 28, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trail-mark dash + eyebrow
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      eyebrow.toUpperCase(),
                      style: GoogleFonts.manrope(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Title
                Text(
                  title,
                  style: GoogleFonts.fraunces(
                    color: AppColors.backgroundDark,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    letterSpacing: -0.4,
                  ),
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: 14),

                // Description
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    color: AppColors.textSecondaryLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Ridge-line silhouette clipper ─────────────────────────
// Cuts the bottom of the photo into a soft skyline, echoing the
// Western Ghats ridgeline Coorg sits in — the signature visual
// detail that ties the intro flow to the actual destination.
class _RidgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.20, h * 0.68, w * 0.40, h * 0.84)
      ..quadraticBezierTo(w * 0.60, h * 0.97, w * 0.78, h * 0.76)
      ..quadraticBezierTo(w * 0.90, h * 0.60, w, h * 0.72)
      ..lineTo(w, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
