import 'package:one_coorg/theme/app_colors.dart';
import 'package:one_coorg/screens/home/towns_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TownDetailScreen extends StatefulWidget {
  final Town town;
  const TownDetailScreen({super.key, required this.town});

  @override
  State<TownDetailScreen> createState() => _TownDetailScreenState();
}

class _TownDetailScreenState extends State<TownDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
      () => setState(() => _scrollOffset = _scrollController.offset),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openMaps() async {
    final query = Uri.encodeComponent("${widget.town.name}, Coorg, Karnataka");
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
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

    final double headerOpacity = (_scrollOffset / 200).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            // ── Scrollable content ───────────────────────────
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // ── Hero image ───────────────────────────────
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 360,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.town.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        AppColors.surfaceDark,
                                        AppColors.cardDark,
                                      ]
                                    : [
                                        AppColors.cardLight,
                                        AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.town.emoji,
                                style: const TextStyle(fontSize: 90),
                              ),
                            ),
                          ),
                        ),
                        // Gradient
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Color(0x88000000),
                                Color(0xEE000000),
                              ],
                              stops: [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                        // Title block
                        Positioned(
                          bottom: 24,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.town.aka.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Text(
                                widget.town.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.town.fullLocation,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // // ── Quick stats ──────────────────────────────
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //       decoration: BoxDecoration(
                //         color: cardBg,
                //         borderRadius: BorderRadius.circular(18),
                //         border: Border.all(color: divider),
                //         boxShadow: isDark
                //             ? []
                //             : [
                //                 BoxShadow(
                //                   color: AppColors.primary.withValues(
                //                     alpha: 0.07,
                //                   ),
                //                   blurRadius: 14,
                //                   offset: const Offset(0, 4),
                //                 ),
                //               ],
                //       ),
                //       child: Row(
                //         children: [
                //           _StatItem(
                //             icon: Icons.wb_sunny_rounded,
                //             iconColor: const Color(0xFFFFC107),
                //             value: widget.town.weather,
                //             label: "WEATHER",
                //             textPri: textPri,
                //             textSec: textSec,
                //           ),
                //           _VertDivider(color: divider),
                //           _StatItem(
                //             icon: Icons.calendar_month_rounded,
                //             iconColor: AppColors.primaryLight,
                //             value: widget.town.bestTime,
                //             label: "BEST TIME",
                //             textPri: textPri,
                //             textSec: textSec,
                //           ),
                //           _VertDivider(color: divider),
                //           _StatItem(
                //             icon: Icons.people_rounded,
                //             iconColor: const Color(0xFF1565C0),
                //             value: widget.town.population,
                //             label: "POPULATION",
                //             textPri: textPri,
                //             textSec: textSec,
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                // ── About ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          title: "About ${widget.town.name}",
                          textPri: textPri,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.town.about,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: textSec,
                            height: 1.7,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // // ── Highlights ───────────────────────────────
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         _SectionTitle(title: "Highlights", textPri: textPri),
                //         const SizedBox(height: 14),
                //         GridView.count(
                //           crossAxisCount: 2,
                //           crossAxisSpacing: 12,
                //           mainAxisSpacing: 12,
                //           shrinkWrap: true,
                //           physics: const NeverScrollableScrollPhysics(),
                //           childAspectRatio: 2.4,
                //           children: widget.town.highlights
                //               .map(
                //                 (h) => Container(
                //                   padding: const EdgeInsets.symmetric(
                //                     horizontal: 12,
                //                     vertical: 10,
                //                   ),
                //                   decoration: BoxDecoration(
                //                     color: cardBg,
                //                     borderRadius: BorderRadius.circular(14),
                //                     border: Border.all(color: divider),
                //                     boxShadow: isDark
                //                         ? []
                //                         : [
                //                             BoxShadow(
                //                               color: AppColors.primary
                //                                   .withValues(alpha: 0.05),
                //                               blurRadius: 8,
                //                               offset: const Offset(0, 2),
                //                             ),
                //                           ],
                //                   ),
                //                   child: Row(
                //                     children: [
                //                       Container(
                //                         padding: const EdgeInsets.all(7),
                //                         decoration: BoxDecoration(
                //                           color: accent.withValues(
                //                             alpha: isDark ? 0.2 : 0.10,
                //                           ),
                //                           borderRadius: BorderRadius.circular(
                //                             8,
                //                           ),
                //                         ),
                //                         child: Icon(
                //                           h["icon"] as IconData,
                //                           size: 16,
                //                           color: accent,
                //                         ),
                //                       ),
                //                       const SizedBox(width: 8),
                //                       Expanded(
                //                         child: Text(
                //                           h["label"] as String,
                //                           maxLines: 2,
                //                           style: TextStyle(
                //                             fontSize: 12,
                //                             fontWeight: FontWeight.w600,
                //                             color: textPri,
                //                             height: 1.3,
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               )
                //               .toList(),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // ── Nearby places ────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(title: "Nearby Places", textPri: textPri),
                        const SizedBox(height: 12),
                        Container(
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
                          child: Column(
                            children: widget.town.nearbyPlaces
                                .asMap()
                                .entries
                                .map((e) {
                                  final bool isLast =
                                      e.key ==
                                      widget.town.nearbyPlaces.length - 1;
                                  final place = e.value;
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 14,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: accent.withValues(
                                                  alpha: isDark ? 0.2 : 0.10,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.place_rounded,
                                                size: 18,
                                                color: accent,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                place["name"] as String,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: textPri,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: accent.withValues(
                                                  alpha: isDark ? 0.2 : 0.08,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                place["dist"] as String,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: accent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isLast)
                                        Divider(
                                          height: 1,
                                          color: divider,
                                          indent: 18,
                                          endIndent: 18,
                                        ),
                                    ],
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Best time card ───────────────────────────
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                //     child: Container(
                //       padding: const EdgeInsets.all(16),
                //       decoration: BoxDecoration(
                //         color: isDark
                //             ? AppColors.primary.withValues(alpha: 0.2)
                //             : AppColors.cardLight,
                //         borderRadius: BorderRadius.circular(16),
                //         border: Border.all(color: divider),
                //       ),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Container(
                //             padding: const EdgeInsets.all(10),
                //             decoration: BoxDecoration(
                //               color: accent.withValues(
                //                 alpha: isDark ? 0.3 : 0.12,
                //               ),
                //               borderRadius: BorderRadius.circular(12),
                //             ),
                //             child: Icon(
                //               Icons.calendar_month_rounded,
                //               color: accent,
                //               size: 22,
                //             ),
                //           ),
                //           const SizedBox(width: 14),
                //           Expanded(
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text(
                //                   "Best Time to Visit",
                //                   style: TextStyle(
                //                     fontSize: 14,
                //                     fontWeight: FontWeight.w700,
                //                     color: textPri,
                //                   ),
                //                 ),
                //                 const SizedBox(height: 4),
                //                 Text(
                //                   widget.town.bestTime,
                //                   style: TextStyle(
                //                     fontSize: 13,
                //                     color: textSec,
                //                   ),
                //                 ),
                //                 const SizedBox(height: 2),
                //                 Text(
                //                   "Weather: ${widget.town.weather}",
                //                   style: TextStyle(
                //                     fontSize: 13,
                //                     color: textSec,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),

            // ── Floating app bar ─────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark.withValues(
                          alpha: headerOpacity,
                        )
                      : Colors.white.withValues(alpha: headerOpacity),
                  boxShadow: headerOpacity > 0.5
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.06 * headerOpacity,
                            ),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _CircleButton(
                          icon: Icons.arrow_back_rounded,
                          scrolled: headerOpacity > 0.5,
                          isDark: isDark,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        _CircleButton(
                          icon: Icons.ios_share_rounded,
                          scrolled: headerOpacity > 0.5,
                          isDark: isDark,
                          onTap: () {
                            // share externally
                            SharePlus.instance.share(
                              ShareParams(
                                subject: widget.town.name,
                                text:
                                    '📍 ${widget.town.name}\n'
                                    '${widget.town.fullLocation}\n\n'
                                    '${widget.town.desc}\n\n'
                                    '🗺️ https://www.google.com/maps/search/?api=1&query=${widget.town.latitude},${widget.town.longitude}',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom bar ───────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  MediaQuery.of(context).padding.bottom + 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  border: Border(top: BorderSide(color: divider)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.07,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: _openMaps,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Explore on Map",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final Color textPri;
  const _SectionTitle({required this.title, required this.textPri});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: textPri,
      letterSpacing: -0.3,
    ),
  );
}

// class _StatItem extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final String value;
//   final String label;
//   final Color textPri;
//   final Color textSec;

//   const _StatItem({
//     required this.icon,
//     required this.iconColor,
//     required this.value,
//     required this.label,
//     required this.textPri,
//     required this.textSec,
//   });

//   @override
//   Widget build(BuildContext context) => Expanded(
//     child: Column(
//       children: [
//         Icon(icon, color: iconColor, size: 22),
//         const SizedBox(height: 5),
//         Text(
//           value,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//             color: textPri,
//             letterSpacing: -0.2,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 9,
//             fontWeight: FontWeight.w600,
//             color: textSec,
//             letterSpacing: 0.8,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _VertDivider extends StatelessWidget {
//   final Color color;
//   const _VertDivider({required this.color});

//   @override
//   Widget build(BuildContext context) =>
//       Container(width: 1, height: 40, color: color);
// }

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool scrolled;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.isDark,
    required this.scrolled,
    required this.onTap,
  }) : iconColor = null;

  @override
  Widget build(BuildContext context) {
    final bool useDark = scrolled ? isDark : true;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: useDark
              ? Colors.black.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color:
              iconColor ??
              (useDark ? Colors.white : AppColors.textPrimaryLight),
        ),
      ),
    );
  }
}
