import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:one_coorg/screens/home/town_detail_screen.dart';

// ── Model ─────────────────────────────────────────────────
class Town {
  final String name;
  final String aka;
  final String desc;
  final String emoji;
  final String imagePath;
  final String fullLocation;
  final String about;
  final List<Map<String, dynamic>> nearbyPlaces;
  final String weather;
  final String population;
  final double latitude;
  final double longitude;

  const Town({
    required this.name,
    required this.aka,
    required this.desc,
    required this.emoji,
    required this.imagePath,
    required this.fullLocation,
    required this.about,
    required this.nearbyPlaces,
    required this.weather,
    required this.population,
    required this.latitude,
    required this.longitude,
  });

  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      name: json['name'],
      aka: json['aka'],
      desc: json['description'],
      emoji: json['emoji'],
      imagePath: json['image_path'],
      fullLocation: json['full_location'],
      about: json['about'],
      nearbyPlaces: List<Map<String, dynamic>>.from(json['nearby_places']),
      weather: json['weather'],
      population: json['population'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

// ── Repository ────────────────────────────────────────────
class TownsRepository {
  final _client = Supabase.instance.client;

  Future<List<Town>> fetchTowns() async {
    final data = await _client.from('towns').select().order('id');
    return (data as List).map((row) => Town.fromJson(row)).toList();
  }
}

// ── Screen ────────────────────────────────────────────────
class TownsScreen extends StatefulWidget {
  const TownsScreen({super.key});

  @override
  State<TownsScreen> createState() => _TownsScreenState();
}

class _TownsScreenState extends State<TownsScreen> {
  final _repo = TownsRepository();
  late Future<List<Town>> _townsFuture;

  @override
  void initState() {
    super.initState();
    _townsFuture = _repo.fetchTowns();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Famous Towns",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textPri,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textPri),
      ),
      body: Container(
        color: bg,
        child: SafeArea(
          child: FutureBuilder<List<Town>>(
            future: _townsFuture,
            builder: (context, snapshot) {
              return CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Famous Towns",
                          //   style: TextStyle(
                          //     fontSize: 34,
                          //     fontWeight: FontWeight.w800,
                          //     color: textPri,
                          //     letterSpacing: -1,
                          //     height: 1.1,
                          //   ),
                          // ),
                          // const SizedBox(height: 4),
                          Text(
                            "Explore Coorg's iconic towns & villages",
                            style: TextStyle(fontSize: 14, color: textSec),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Loading ──────────────────────────────
                  if (snapshot.connectionState == ConnectionState.waiting)
                    SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  // ── Error ────────────────────────────────
                  else if (snapshot.hasError)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 48,
                              color: textSec,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Couldn't load towns",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textPri,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Check your connection and try again",
                              style: TextStyle(fontSize: 13, color: textSec),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () => setState(
                                () => _townsFuture = _repo.fetchTowns(),
                              ),
                              icon: Icon(
                                Icons.refresh_rounded,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                "Retry",
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // ── Empty ────────────────────────────────
                  else if (!snapshot.hasData || snapshot.data!.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "No towns found",
                          style: TextStyle(fontSize: 15, color: textSec),
                        ),
                      ),
                    )
                  // ── List ─────────────────────────────────
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _TownCard(
                            town: snapshot.data![index],
                            isDark: isDark,
                            textPri: textPri,
                            textSec: textSec,
                          ),
                          childCount: snapshot.data!.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Town Card ─────────────────────────────────────────────
class _TownCard extends StatelessWidget {
  final Town town;
  final bool isDark;
  final Color textPri;
  final Color textSec;

  const _TownCard({
    required this.town,
    required this.isDark,
    required this.textPri,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = isDark ? AppColors.cardDark : Colors.white;
    final Color divider = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TownDetailScreen(town: town)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: divider) : null,
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
            // ── Image ──────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    town.imagePath,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 170,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.surfaceDark, AppColors.cardDark]
                              : [AppColors.cardLight, AppColors.dividerLight],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          town.emoji,
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Town name + aka pill
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            town.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            town.aka,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Description + arrow ────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      town.desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: textSec,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : AppColors.cardLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.primaryBright
                          : AppColors.primary,
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
