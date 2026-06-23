import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/providers/favourites_provider.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailScreen extends StatefulWidget {
  final TouristPlace place;
  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
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

  // updated

  Future<void> _openDirections() async {
    final lat = widget.place.lat;
    final lng = widget.place.lng;
    final name = Uri.encodeComponent(widget.place.name);

    // Try Google Maps app first, fall back to browser
    final googleMapsApp = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    final googleMapsBrowser = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination=$name&travelmode=driving",
    );

    if (await canLaunchUrl(googleMapsApp)) {
      await launchUrl(googleMapsApp, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(googleMapsBrowser)) {
      await launchUrl(googleMapsBrowser, mode: LaunchMode.externalApplication);
    } else {
      // Final fallback — open in any available browser
      await launchUrl(googleMapsBrowser, mode: LaunchMode.platformDefault);
    }
  }

  // Future<void> _openDirections() async {
  //   print("Opening directions for ${widget.place.name}");
  //   final lat = widget.place.lat;
  //   final lng = widget.place.lng;
  //   final name = Uri.encodeComponent(widget.place.name);
  //   final url = Uri.parse(
  //     "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$name",
  //   );
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url, mode: LaunchMode.externalApplication);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final p = widget.place; // shorthand
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final notifier = FavouritesProvider.of(context);
    final isFavourite = notifier.isFavourite(p);

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

    final double headerOpacity = (_scrollOffset / 200).clamp(0.0, 1.0);

    // About section title based on category
    final String aboutTitle = switch (p.category) {
      "Waterfalls" => "About the Falls",
      "Temples" => "About the Temple",
      "Wildlife" => "About the Reserve",
      _ => "About the Place",
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            // ── Scrollable body ──────────────────────────────
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // ── Hero image ─────────────────────────────
                SliverToBoxAdapter(
                  child: _HeroSection(
                    place: p,
                    isDark: isDark,
                    isFavourite: isFavourite,
                    onFavouriteTap: () => notifier.toggle(p),
                  ),
                ),

                // ── Stats row ──────────────────────────────
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(vertical: 18),
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
                //             icon: Icons.star_rounded,
                //             iconColor: const Color(0xFFFFC107),
                //             value: p.rating.toString(),
                //             label: "RATING",
                //             isDark: isDark,
                //           ),
                //           _VertDivider(isDark: isDark),
                //           _StatItem(
                //             icon: Icons.schedule_rounded,
                //             iconColor: AppColors.primaryLight,
                //             value: p.duration,
                //             label: "DURATION",
                //             isDark: isDark,
                //           ),
                //           _VertDivider(isDark: isDark),
                //           _StatItem(
                //             icon: Icons.thermostat_rounded,
                //             iconColor: const Color(0xFF1565C0),
                //             value: p.temp,
                //             label: "TEMP",
                //             isDark: isDark,
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                // ── About ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(title: aboutTitle, textPri: textPri),
                        const SizedBox(height: 10),
                        Text(
                          p.about,
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

                // ── Activities ──────────────────────────────
                if (p.activities.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(title: "Activities", textPri: textPri),
                          const SizedBox(height: 14),
                          Row(
                            children: p.activities.map((label) {
                              final icon =
                                  activityIconMap[label] ??
                                  Icons.star_outline_rounded;
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: divider),
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        icon,
                                        size: 22,
                                        color: isDark
                                            ? AppColors.primaryBright
                                            : AppColors.primary,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        label,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: textSec,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Best Time ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: divider),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  (isDark
                                          ? AppColors.primaryBright
                                          : AppColors.primary)
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Best Time to Visit",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textPri,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.bestTime,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: textSec,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Map tile ────────────────────────────────
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         _SectionTitle(title: "Location", textPri: textPri),
                //         const SizedBox(height: 12),
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(18),
                //           child: Stack(
                //             children: [
                //               Image.network(
                //                 "https://tile.openstreetmap.org/14/"
                //                 "${_lngToTileX(p.lng, 14)}/"
                //                 "${_latToTileY(p.lat, 14)}.png",
                //                 height: 160,
                //                 width: double.infinity,
                //                 fit: BoxFit.cover,
                //                 errorBuilder: (_, _, _) => Container(
                //                   height: 160,
                //                   color: isDark
                //                       ? AppColors.surfaceDark
                //                       : AppColors.cardLight,
                //                   child: Center(
                //                     child: Icon(
                //                       Icons.map_outlined,
                //                       color: textSec,
                //                       size: 36,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //               // Pin overlay
                //               Positioned.fill(
                //                 child: Center(
                //                   child: Icon(
                //                     Icons.location_on_rounded,
                //                     color: AppColors.accent,
                //                     size: 32,
                //                   ),
                //                 ),
                //               ),
                //               // Label chip
                //               Positioned(
                //                 bottom: 10,
                //                 left: 10,
                //                 child: Container(
                //                   padding: const EdgeInsets.symmetric(
                //                     horizontal: 10,
                //                     vertical: 5,
                //                   ),
                //                   decoration: BoxDecoration(
                //                     color: Colors.white.withValues(alpha: 0.92),
                //                     borderRadius: BorderRadius.circular(8),
                //                   ),
                //                   child: Text(
                //                     p.mapLabel,
                //                     style: const TextStyle(
                //                       fontSize: 12,
                //                       fontWeight: FontWeight.w600,
                //                       color: Color(0xFF1B2E1B),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //               // Open map text button
                //               Positioned(
                //                 bottom: 10,
                //                 right: 10,
                //                 child: GestureDetector(
                //                   onTap: _openDirections,
                //                   child: Container(
                //                     padding: const EdgeInsets.symmetric(
                //                       horizontal: 10,
                //                       vertical: 5,
                //                     ),
                //                     decoration: BoxDecoration(
                //                       color: AppColors.accent,
                //                       borderRadius: BorderRadius.circular(8),
                //                     ),
                //                     child: const Text(
                //                       "OPEN MAP",
                //                       style: TextStyle(
                //                         fontSize: 10,
                //                         fontWeight: FontWeight.w700,
                //                         color: Colors.white,
                //                         letterSpacing: 0.5,
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
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
                          isDark: isDark,
                          scrolled: headerOpacity > 0.5,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        _CircleButton(
                          icon: Icons.ios_share_rounded,
                          isDark: isDark,
                          scrolled: headerOpacity > 0.5,
                          onTap: () {
                            // share externally
                            SharePlus.instance.share(
                              ShareParams(
                                subject: p.name,
                                text:
                                    '📍 ${p.name}\n'
                                    '${p.fullLocation}\n\n'
                                    '${p.description}\n\n'
                                    '⭐ Rating: ${p.rating}  '
                                    '🕐 Duration: ${p.duration}  '
                                    '🎟️ Entry: ${p.entryFee}\n\n'
                                    '🗺️ https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lng}',
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _CircleButton(
                          icon: isFavourite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          isDark: isDark,
                          scrolled: headerOpacity > 0.5,
                          iconColor: isFavourite ? Colors.redAccent : null,
                          onTap: () => notifier.toggle(p),
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
                child: Row(
                  children: [
                    // Entry fee
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Entry Fee",
                          style: TextStyle(
                            fontSize: 11,
                            color: textSec,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.entryFee,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPri,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _openDirections,
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
                              Icon(
                                Icons.directions_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Get Directions",
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // // OSM tile coordinate helpers
  // int _lngToTileX(double lng, int zoom) =>
  //     ((lng + 180) / 360 * (1 << zoom)).floor();

  // int _latToTileY(double lat, int zoom) {
  //   final latRad = lat * 3.141592653589793 / 180;
  //   return ((1 - (log(tan(latRad) + 1 / cos(latRad)) / 3.141592653589793)) /
  //           2 *
  //           (1 << zoom))
  //       .floor();
  // }
}

// ignore: non_constant_identifier_names
double log(double x) => x <= 0 ? 0 : _log(x);
double _log(double x) {
  double result = 0;
  double term = (x - 1) / (x + 1);
  double term2 = term * term;
  double current = term;
  for (int i = 1; i <= 20; i++) {
    result += current / (2 * i - 1);
    current *= term2;
  }
  return 2 * result;
}

double tan(double x) => sin(x) / cos(x);
double sin(double x) {
  x = x % (2 * 3.141592653589793);
  double result = 0, term = x;
  for (int i = 1; i <= 10; i++) {
    result += term;
    term *= -x * x / ((2 * i) * (2 * i + 1));
  }
  return result;
}

double cos(double x) {
  x = x % (2 * 3.141592653589793);
  double result = 0, term = 1;
  for (int i = 1; i <= 10; i++) {
    result += term;
    term *= -x * x / ((2 * i - 1) * (2 * i));
  }
  return result;
}

// ── Hero section ──────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final TouristPlace place;
  final bool isDark;
  final bool isFavourite;
  final VoidCallback onFavouriteTap;

  const _HeroSection({
    required this.place,
    required this.isDark,
    required this.isFavourite,
    required this.onFavouriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            place.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColors.primaryBright
                            : AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
            errorBuilder: (_, _, _) => Container(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              child: Center(
                child: Text(place.emoji, style: const TextStyle(fontSize: 80)),
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0x88000000),
                  Color(0xDD000000),
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          // Title
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (place.isTopRated)
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
                    child: const Text(
                      "TOP RATED",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place.fullLocation,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────
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
    this.iconColor,
  });

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
