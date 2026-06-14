import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/screens/home/place_detail_screen.dart';
import 'package:one_coorg/services/place_service.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';

// ── Categories ────────────────────────────────────────────
const List<Map<String, dynamic>> _categories = [
  {"label": "All", "icon": Icons.grid_view_rounded},
  {"label": "Waterfalls", "icon": Icons.water_rounded},
  {"label": "Wildlife", "icon": Icons.pets_rounded},
  {"label": "Temples", "icon": Icons.temple_hindu_rounded},
  {"label": "Viewpoints", "icon": Icons.panorama_rounded},
  {"label": "Trekking", "icon": Icons.hiking_rounded},
];

const Map<String, Color> _categoryAccents = {
  "All": AppColors.primary,
  "Waterfalls": Color(0xFF1565C0),
  "Wildlife": Color(0xFF6D4C41),
  "Temples": Color(0xFFE65100),
  "Viewpoints": Color(0xFF6A1B9A),
  "Trekking": AppColors.primaryLight,
};

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = "All";
  String _searchQuery = "";

  // Holds the one active future — recreated only when category changes
  late Future<List<TouristPlace>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = PlaceService.fetchPlaces();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _placesFuture = PlaceService.fetchPlaces(category: category);
      _searchQuery = ""; // reset search on category switch
    });
  }

  // Client-side search filter applied on top of fetched list
  List<TouristPlace> _applySearch(List<TouristPlace> places) {
    if (_searchQuery.isEmpty) return places;
    final q = _searchQuery.toLowerCase();
    return places
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.location.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final Color textPri = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color textSec = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final Color cardBg = isDark ? AppColors.cardDark : Colors.white;
    final Color inputBg = isDark ? AppColors.cardDark : Colors.white;
    final Color divider = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;

    return Container(
      color: bg,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.25 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Kodagu, Karnataka",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Discover\n",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: textPri,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                          TextSpan(
                            text: "Coorg's Wonders",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: divider),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: TextStyle(fontSize: 14, color: textPri),
                        decoration: InputDecoration(
                          hintText: "Search places, landmarks...",
                          hintStyle: TextStyle(
                            color: textSec.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.primaryLight,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () =>
                                      setState(() => _searchQuery = ""),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: textSec,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Category chips ───────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final label = cat["label"] as String;
                    final isActive = label == _selectedCategory;
                    final accent = _categoryAccents[label] ?? AppColors.primary;
                    return GestureDetector(
                      onTap: () => _onCategorySelected(label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? accent
                              : isDark
                              ? AppColors.cardDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isActive ? accent : divider,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cat["icon"] as IconData,
                              size: 14,
                              color: isActive ? Colors.white : textSec,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : textSec,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Places list via FutureBuilder ────────────────
            SliverToBoxAdapter(
              child: FutureBuilder<List<TouristPlace>>(
                future: _placesFuture,
                builder: (context, snapshot) {
                  // ── Loading ──────────────────────────────
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: isDark
                              ? AppColors.primaryBright
                              : AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  }

                  // ── Error ────────────────────────────────
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 40,
                            color: textSec,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Couldn't load places",
                            style: TextStyle(
                              color: textSec,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(() {
                              _placesFuture = PlaceService.fetchPlaces(
                                category: _selectedCategory,
                              );
                            }),
                            child: Text(
                              "Tap to retry",
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.primaryBright
                                    : AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filtered = _applySearch(snapshot.data ?? []);

                  // ── Empty ────────────────────────────────
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: textSec,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No places found",
                            style: TextStyle(
                              color: textSec,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // ── List ─────────────────────────────────
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      children: filtered
                          .map(
                            (place) => _PlaceCard(
                              place: place,
                              cardBg: cardBg,
                              textPri: textPri,
                              textSec: textSec,
                              isDark: isDark,
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Place card ────────────────────────────────────────────
class _PlaceCard extends StatelessWidget {
  final TouristPlace place;
  final Color cardBg;
  final Color textPri;
  final Color textSec;
  final bool isDark;

  const _PlaceCard({
    required this.place,
    required this.cardBg,
    required this.textPri,
    required this.textSec,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = _categoryAccents[place.category] ?? AppColors.primary;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: AppColors.dividerDark) : null,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  // Network image from Supabase Storage
                  Image.network(
                    place.imageUrl,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            height: 190,
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
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
                      height: 190,
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      child: Center(
                        child: Text(
                          place.emoji,
                          style: const TextStyle(fontSize: 52),
                        ),
                      ),
                    ),
                  ),
                  // Gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        place.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                            letterSpacing: -0.3,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            place.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: textSec,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 2,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSec,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
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
