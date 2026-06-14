import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/providers/favourites_provider.dart';
import 'package:one_coorg/screens/home/place_detail_screen.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';

const Map<String, Color> _categoryAccents = {
  "Waterfalls": Color(0xFF1565C0),
  "Wildlife": Color(0xFF6D4C41),
  "Temples": Color(0xFFE65100),
  "Viewpoints": Color(0xFF6A1B9A),
  "Trekking": AppColors.primaryLight,
};

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

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
    final notifier = FavouritesProvider.of(context);

    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        // Spinner while SharedPreferences loads on cold start
        if (!notifier.isLoaded) {
          return Container(
            color: bg,
            child: Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.primaryBright : AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final favourites = notifier.favourites;

        return Container(
          color: bg,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Favourites",
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: textPri,
                                  letterSpacing: -1,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                favourites.isEmpty
                                    ? "Your saved places will appear here"
                                    : "${favourites.length} place${favourites.length == 1 ? '' : 's'} saved",
                                style: TextStyle(fontSize: 14, color: textSec),
                              ),
                            ],
                          ),
                        ),
                        if (favourites.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primary.withValues(alpha: 0.25)
                                  : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: divider),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite_rounded,
                                  size: 14,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${favourites.length}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Empty state ──────────────────────────────
                if (favourites.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.cardLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            size: 40,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No favourites yet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textSec,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 52),
                          child: Text(
                            "Tap the ♡ on any place detail screen to save it here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: textSec.withValues(alpha: 0.65),
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),

                // ── List ─────────────────────────────────────
                if (favourites.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final place = favourites[index];
                        final Color accent =
                            _categoryAccents[place.category] ??
                            AppColors.primary;

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailScreen(place: place),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: isDark
                                  ? Border.all(color: divider)
                                  : null,
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    place.imageUrl,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 110,
                                      height: 110,
                                      color: isDark
                                          ? AppColors.surfaceDark
                                          : AppColors.cardLight,
                                      child: Center(
                                        child: Text(
                                          place.emoji,
                                          style: const TextStyle(fontSize: 36),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Info
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      14,
                                      8,
                                      14,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accent.withValues(
                                              alpha: isDark ? 0.25 : 0.10,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            place.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: accent,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          place.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: textPri,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 12,
                                              color: textSec,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              place.location,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: textSec,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Remove button
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () => _confirmRemove(
                                      context,
                                      place,
                                      notifier,
                                      isDark,
                                    ),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(
                                          alpha: isDark ? 0.2 : 0.08,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.favorite_rounded,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: favourites.length),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmRemove(
    BuildContext context,
    TouristPlace place,
    FavouritesNotifier notifier,
    bool isDark,
  ) {
    final Color sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
    final Color textPri = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color textSec = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "Remove from Favourites?",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPri,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "\"${place.name}\" will be removed from your saved places.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: textSec, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPri,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      notifier.toggle(place);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Remove",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
