import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    // mailto links skip canLaunchUrl check — it's unreliable on Android
    if (uri.scheme == 'mailto') {
      await launchUrl(uri);
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final Color cardBg = isDark ? AppColors.cardDark : Colors.white;
    final Color textPri = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color textSec = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final Color divider = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;
    final Color accent = isDark ? AppColors.primaryBright : AppColors.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        body: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final String version = snapshot.data?.version ?? "—";
            final String buildNumber = snapshot.data?.buildNumber ?? "—";

            return CustomScrollView(
              slivers: [
                // ── App bar ──────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  foregroundColor: textPri,
                  elevation: 0,
                  scrolledUnderElevation: 1,
                  shadowColor: AppColors.primary.withValues(alpha: 0.1),
                  title: Text(
                    "About",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textPri,
                    ),
                  ),
                  centerTitle: true,
                ),

                // ── Hero card ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [AppColors.surfaceDark, AppColors.cardDark]
                            : [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: isDark ? 0.2 : 0.35,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // App icon
                        Image.asset(
                          "assets/images/logo_round.png",
                          height: 80,
                          width: 80,
                        ),
                        const SizedBox(height: 16),

                        // App name
                        const Text(
                          "One Coorg",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Tagline
                        Text(
                          "Discover the Scotland of India",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Version pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            "Version $version (Build $buildNumber)",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── About the app ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          title: "About the App",
                          textPri: textPri,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: divider),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Text(
                            "One Coorg is your complete travel companion for Kodagu, Karnataka — the lush hill station nestled in the Western Ghats. Whether you're planning your first trip or your fifth, we help you discover iconic waterfalls, wildlife sanctuaries, ancient temples, misty viewpoints, coffee plantations, and the best places to stay.\n\nOur mission is simple: to make every visit to Coorg more meaningful, more memorable, and more adventurous.",
                            style: TextStyle(
                              fontSize: 14,
                              color: textSec,
                              height: 1.7,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Key features ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(title: "Features", textPri: textPri),
                        const SizedBox(height: 12),
                        ...[
                          _FeatureItem(
                            icon: Icons.explore_rounded,
                            label: "Explore Tourist Places",
                            desc:
                                "Discover Coorg's best spots by category — waterfalls, wildlife, temples, trekking & more.",
                            isDark: isDark,
                            cardBg: cardBg,
                            divider: divider,
                            textPri: textPri,
                            textSec: textSec,
                            accent: accent,
                          ),
                          _FeatureItem(
                            icon: Icons.location_city_rounded,
                            label: "Famous Towns Guide",
                            desc:
                                "Learn about iconic towns like Madikeri, Kushalnagar, Somwarpet and their hidden stories.",
                            isDark: isDark,
                            cardBg: cardBg,
                            divider: divider,
                            textPri: textPri,
                            textSec: textSec,
                            accent: accent,
                          ),
                          _FeatureItem(
                            icon: Icons.cabin_rounded,
                            label: "Stays & Hotels",
                            desc: "FEATURE COMING SOON",
                            isDark: isDark,
                            cardBg: cardBg,
                            divider: divider,
                            textPri: textPri,
                            textSec: textSec,
                            accent: accent,
                          ),
                          _FeatureItem(
                            icon: Icons.eco_rounded,
                            label: "Plantation Experiences",
                            desc: "FEATURE COMING SOON",
                            isDark: isDark,
                            cardBg: cardBg,
                            divider: divider,
                            textPri: textPri,
                            textSec: textSec,
                            accent: accent,
                          ),
                          _FeatureItem(
                            icon: Icons.directions_car_rounded,
                            label: "Precise Directions",
                            desc:
                                "One tap to get the precise directions to any place via Google Maps.",
                            isDark: isDark,
                            cardBg: cardBg,
                            divider: divider,
                            textPri: textPri,
                            textSec: textSec,
                            accent: accent,
                            isLast: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── App info ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(title: "App Info", textPri: textPri),
                        const SizedBox(height: 12),
                        _InfoCard(
                          isDark: isDark,
                          cardBg: cardBg,
                          divider: divider,
                          children: [
                            _InfoRow(
                              label: "Version",
                              value: "$version ($buildNumber)",
                              textPri: textPri,
                              textSec: textSec,
                              divider: divider,
                            ),
                            _InfoRow(
                              label: "Platform",
                              value: "Flutter (Android & iOS)",
                              textPri: textPri,
                              textSec: textSec,
                              divider: divider,
                            ),
                            _InfoRow(
                              label: "Last Updated",
                              value: "March 2026",
                              textPri: textPri,
                              textSec: textSec,
                              divider: divider,
                            ),
                            _InfoRow(
                              label: "Region",
                              value: "Kodagu, Karnataka, India",
                              textPri: textPri,
                              textSec: textSec,
                              divider: divider,
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Links ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(title: "Links", textPri: textPri),
                        const SizedBox(height: 12),
                        _InfoCard(
                          isDark: isDark,
                          cardBg: cardBg,
                          divider: divider,
                          children: [
                            _LinkRow(
                              icon: Icons.privacy_tip_outlined,
                              label: "Privacy Policy",
                              isDark: isDark,
                              textPri: textPri,
                              textSec: textSec,
                              divider: divider,
                              accent: accent,
                              onTap: () => _launchUrl(
                                "https://www.termsfeed.com/live/c195b57d-7ca6-4880-9e39-ce0d2343cda4",
                              ),
                            ),

                            _LinkRow(
                              icon: Icons.star_outline_rounded,
                              label: "Rate the App",
                              isDark: isDark,
                              textPri: textPri,
                              textSec: textSec,
                              divider: divider,
                              accent: accent,
                              onTap: () => _launchUrl(
                                "https://play.google.com/store/apps/details?id=com.shezinstudio.one_coorg",
                              ),
                            ),
                            _LinkRow(
                              icon: Icons.bug_report_outlined,
                              label: "Report an Issue",
                              isDark: isDark,
                              textPri: textPri,
                              textSec: textSec,
                              divider: divider,
                              accent: accent,
                              onTap: () =>
                                  _launchUrl("mailto:onecoorg.admin@gmail.com"),
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Made with love ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
                    child: Column(
                      children: [
                        // Divider
                        Container(height: 1, color: divider),
                        const SizedBox(height: 28),

                        // Coorg icon
                        Image.asset(
                          "assets/images/logo_round.png",
                          height: 48,
                          width: 48,
                        ),
                        const SizedBox(height: 14),

                        // Made with love text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Made with ",
                              style: TextStyle(fontSize: 13, color: textSec),
                            ),
                            const Icon(
                              Icons.favorite_rounded,
                              color: Colors.redAccent,
                              size: 14,
                            ),
                            Text(
                              " for Coorg",
                              style: TextStyle(fontSize: 13, color: textSec),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "© 2026 One Coorg. All rights reserved.",
                          style: TextStyle(
                            fontSize: 11,
                            color: textSec.withValues(alpha: 0.6),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textPri;
  const _SectionHeader({required this.title, required this.textPri});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: textPri,
        letterSpacing: -0.3,
      ),
    );
  }
}

// ── Feature item ──────────────────────────────────────────
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool isDark;
  final Color cardBg;
  final Color divider;
  final Color textPri;
  final Color textSec;
  final Color accent;
  final bool isLast;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.desc,
    required this.isDark,
    required this.cardBg,
    required this.divider,
    required this.textPri,
    required this.textSec,
    required this.accent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.2 : 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(fontSize: 13, color: textSec, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info card wrapper ─────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color divider;
  final List<Widget> children;

  const _InfoCard({
    required this.isDark,
    required this.cardBg,
    required this.divider,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: divider),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Info row ──────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textPri;
  final Color textSec;
  final Color divider;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.textPri,
    required this.textSec,
    required this.divider,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: textSec,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: textPri,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: divider, indent: 18, endIndent: 18),
      ],
    );
  }
}

// ── Link row ──────────────────────────────────────────────
class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color textPri;
  final Color textSec;
  final Color divider;
  final Color accent;
  final VoidCallback onTap;
  final bool isLast;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.textPri,
    required this.textSec,
    required this.divider,
    required this.accent,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isLast ? 0 : 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Icon(icon, size: 20, color: accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: textPri,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: textSec.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: divider, indent: 52, endIndent: 18),
      ],
    );
  }
}
