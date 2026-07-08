import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/screens/home/place_detail_screen.dart';
import 'package:one_coorg/services/place_service.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:one_coorg/widgets/banner_ad_widget.dart';

const int _adEvery = 5; // show a banner after every 5 cards

const List<Map<String, dynamic>> _categories = [
  {"label": "All", "icon": Icons.grid_view_rounded},
  {"label": "Waterfalls", "icon": Icons.water_rounded},
  {"label": "Temples", "icon": Icons.temple_hindu_rounded},
  {"label": "Viewpoints", "icon": Icons.panorama_rounded},
  {"label": "Heritage", "icon": Icons.history_edu_rounded},
  {"label": "Reservoirs", "icon": Icons.water},
];

const Map<String, Color> _categoryAccents = {
  "All": AppColors.primary,
  "Waterfalls": Color(0xFF1565C0),
  "Temples": Color(0xFFE65100),
  "Viewpoints": Color(0xFF6A1B9A),
  "Heritage": Color(0xFF6D4C41),
  "Reservoirs": AppColors.primaryLight,
};

// Quick filter chips — combined with the category row above as an AND filter
const List<String> _quickFilters = [
  "All",
  "Nearby",
  "Free",
  "Family",
  "Adventure",
];

const Map<String, IconData> _quickFilterIcons = {
  "All": Icons.apps_rounded,
  "Nearby": Icons.near_me_rounded,
  "Free": Icons.money_off_rounded,
  "Family": Icons.family_restroom_rounded,
  "Adventure": Icons.terrain_rounded,
};

const Map<String, String> _quickFilterSubtitles = {
  "All": "Show every place",
  "Nearby": "Within 20 km of you",
  "Free": "No entry fee",
  "Family": "Good for kids",
  "Adventure": "Treks, camping & more",
};

// How far counts as "nearby", in kilometres
const double _nearbyRadiusKm = 20.0;

class ExploreScreen extends StatefulWidget {
  // Lets callers (e.g. tapping a category on the Home screen) open Explore
  // pre-filtered to a specific category instead of always defaulting to
  // "All". Must match one of the labels in _categories, e.g. "Waterfalls".
  final String? initialCategory;

  const ExploreScreen({super.key, this.initialCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late String _selectedCategory;
  String _selectedQuickFilter = "All";
  String _searchQuery = "";

  // Holds the one active future — recreated only when category changes
  late Future<List<TouristPlace>> _placesFuture;

  // In-memory cache keyed by category. Once a category has been fetched in
  // this session, switching back to it (or revisiting this screen while it
  // stays mounted) is instant — no network round trip.
  final Map<String, List<TouristPlace>> _cache = {};

  // User's live position, fetched lazily the first time "Nearby" is tapped
  Position? _userPosition;
  bool _locatingUser = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    final validLabels = _categories.map((c) => c["label"] as String).toSet();
    _selectedCategory =
        (widget.initialCategory != null &&
            validLabels.contains(widget.initialCategory))
        ? widget.initialCategory!
        : "All";
    _placesFuture = _loadPlaces(_selectedCategory);
  }

  // Fetches (or reuses a cached) list for [category], then hands back a
  // freshly shuffled COPY. Shuffling a copy — rather than shuffling the
  // cached list in place — means the cached source order is stable and
  // every call (cached or not) still produces a new random order, so the
  // grid reshuffles each time the screen/category loads without needing to
  // refetch from the network.
  Future<List<TouristPlace>> _loadPlaces(
    String category, {
    bool forceRefresh = false,
  }) async {
    List<TouristPlace> places;
    if (!forceRefresh && _cache.containsKey(category)) {
      places = _cache[category]!;
    } else {
      places = category == "All"
          ? await PlaceService.fetchPlaces()
          : await PlaceService.fetchPlaces(category: category);
      _cache[category] = places;
    }
    return List<TouristPlace>.from(places)..shuffle();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _placesFuture = _loadPlaces(category);
      _searchQuery = ""; // reset search on category switch
    });
  }

  Future<void> _openFilterSheet() async {
    String tempSelected = _selectedQuickFilter;
    bool sheetLocating = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final sheetBg = isDark ? AppColors.cardDark : Colors.white;
        final textPri = isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight;
        final textSec = isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;
        final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> selectFilter(String filter) async {
              if (filter == "Nearby" && _userPosition == null) {
                setSheetState(() => sheetLocating = true);
                await _getUserLocation();
                setSheetState(() => sheetLocating = false);
                if (_userPosition == null) return; // permission denied/failed
              }
              setSheetState(() => tempSelected = filter);
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              "Filter Places",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textPri,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const Spacer(),
                            if (tempSelected != "All")
                              GestureDetector(
                                onTap: () =>
                                    setSheetState(() => tempSelected = "All"),
                                child: Text(
                                  "Reset",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.primaryBright
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Filter options
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: Column(
                          children: _quickFilters.map((filter) {
                            final isActive = filter == tempSelected;
                            final isLoadingThis =
                                filter == "Nearby" && sheetLocating;
                            final accent = isDark
                                ? AppColors.primaryBright
                                : AppColors.primary;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: isLoadingThis
                                    ? null
                                    : () => selectFilter(filter),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? accent.withValues(alpha: 0.12)
                                        : (isDark
                                              ? AppColors.backgroundDark
                                              : AppColors.backgroundLight),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isActive ? accent : divider,
                                      width: isActive ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? accent
                                              : accent.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: isLoadingThis
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: isActive
                                                          ? Colors.white
                                                          : accent,
                                                    ),
                                              )
                                            : Icon(
                                                _quickFilterIcons[filter],
                                                size: 18,
                                                color: isActive
                                                    ? Colors.white
                                                    : accent,
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              filter,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: textPri,
                                              ),
                                            ),
                                            Text(
                                              _quickFilterSubtitles[filter] ??
                                                  '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: textSec,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        child: isActive
                                            ? Icon(
                                                Icons.check_circle_rounded,
                                                key: const ValueKey('active'),
                                                color: accent,
                                                size: 22,
                                              )
                                            : Icon(
                                                Icons.circle_outlined,
                                                key: const ValueKey('inactive'),
                                                color: divider,
                                                size: 22,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Apply button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              setState(
                                () => _selectedQuickFilter = tempSelected,
                              );
                              Navigator.pop(sheetContext);
                            },
                            child: const Text(
                              "Apply Filter",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _locatingUser = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are turned off';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permission permanently denied. Enable it in Settings.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      if (!mounted) return;
      setState(() {
        _userPosition = position;
        _locatingUser = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e.toString();
        _locatingUser = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_locationError!)));
    }
  }

  double _distanceKm(TouristPlace place) {
    if (_userPosition == null) return double.infinity;
    return Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          place.lat,
          place.lng,
        ) /
        1000;
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

  // Quick-filter logic — combined with category (already applied via
  // _placesFuture) and search as an AND filter
  List<TouristPlace> _applyQuickFilter(List<TouristPlace> places) {
    switch (_selectedQuickFilter) {
      case "Free":
        return places
            .where((p) => p.entryFee.toLowerCase().contains('free'))
            .toList();
      case "Family":
        return places.where((p) => p.isFamilyFriendly).toList();
      case "Adventure":
        return places.where((p) => p.isAdventure).toList();
      case "Nearby":
        if (_userPosition == null) return places;
        final withinRadius = places
            .where((p) => _distanceKm(p) <= _nearbyRadiusKm)
            .toList();
        withinRadius.sort((a, b) => _distanceKm(a).compareTo(_distanceKm(b)));
        return withinRadius;
      case "All":
      default:
        return places;
    }
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

    return Scaffold(
      body: Container(
        color: bg,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── App bar ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Explore icon (replaces the drawer/hamburger icon)
                          Icon(
                            Icons.explore_rounded,
                            size: 26,
                            color: isDark
                                ? AppColors.primaryBright
                                : AppColors.primary,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Explore",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: textPri,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ),
                          // Filter action — opens the filter bottom sheet
                          GestureDetector(
                            onTap: _openFilterSheet,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _selectedQuickFilter != "All"
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 22,
                                    color: isDark
                                        ? AppColors.primaryBright
                                        : AppColors.primary,
                                  ),
                                  if (_selectedQuickFilter != "All")
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: bg,
                                            width: 1.5,
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
                      const SizedBox(height: 18),

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

              const SliverToBoxAdapter(child: SizedBox(height: 4)),

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
                      final accent =
                          _categoryAccents[label] ?? AppColors.primary;
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
              // NOTE: this FutureBuilder is now a direct sliver (not wrapped in
              // a single SliverToBoxAdapter). Its loading/error/empty states
              // return SliverToBoxAdapter, but the data state returns a real
              // SliverList — so cards are built lazily as they scroll into
              // view instead of all at once.
              FutureBuilder<List<TouristPlace>>(
                future: _placesFuture,
                builder: (context, snapshot) {
                  // ── Loading ──────────────────────────────
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: isDark
                                ? AppColors.primaryBright
                                : AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    );
                  }

                  // ── Error ────────────────────────────────
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Padding(
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
                                _placesFuture = _loadPlaces(
                                  _selectedCategory,
                                  forceRefresh: true,
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
                      ),
                    );
                  }

                  // Combined AND filter: category (already applied via future)
                  // → search → quick filter (Nearby/Free/Family/Adventure)
                  final searched = _applySearch(snapshot.data ?? []);
                  final filtered = _applyQuickFilter(searched);

                  // ── Empty ────────────────────────────────
                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
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
                      ),
                    );
                  }

                  // ── List (lazy) ───────────────────────────
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Every (_adEvery + 1) items, one slot is an ad
                          final int cyclePos = index % (_adEvery + 1);
                          if (cyclePos == _adEvery) {
                            return const BannerAdWidget();
                          }
                          final int placeIndex =
                              (index ~/ (_adEvery + 1)) * _adEvery + cyclePos;
                          if (placeIndex >= filtered.length) return null;
                          return _PlaceCard(
                            place: filtered[placeIndex],
                            cardBg: cardBg,
                            textPri: textPri,
                            textSec: textSec,
                            isDark: isDark,
                          );
                        },
                        // Total slots = full cycles + remainder + ad count
                        childCount:
                            filtered.length +
                            (filtered.length / _adEvery).floor(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
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

    // Decode the network image at (roughly) its display resolution instead
    // of full size — this cuts memory use and decode time a lot for large
    // source photos, especially noticeable once many cards are on screen.
    final int decodeWidth =
        (MediaQuery.of(context).size.width *
                MediaQuery.of(context).devicePixelRatio)
            .round();

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
                    cacheWidth: decodeWidth,
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
