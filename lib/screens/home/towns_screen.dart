import 'package:one_coorg/theme/app_colors.dart';
import 'package:one_coorg/screens/home/town_detail_screen.dart';
import 'package:flutter/material.dart';

class Town {
  final String name;
  final String aka;
  final String desc;
  final String emoji;
  final String imagePath;
  final String fullLocation;
  final String about;
  final List<Map<String, dynamic>> highlights;
  final List<Map<String, dynamic>> nearbyPlaces;
  final String bestTime;
  final String weather;
  final String population;

  const Town({
    required this.name,
    required this.aka,
    required this.desc,
    required this.emoji,
    required this.imagePath,
    required this.fullLocation,
    required this.about,
    required this.highlights,
    required this.nearbyPlaces,
    required this.bestTime,
    required this.weather,
    required this.population,
  });
}

const List<Town> allTowns = [
  Town(
    name: "Madikeri",
    aka: "Mercara",
    emoji: "🏛️",
    imagePath: "assets/images/madikeri.jpg",
    fullLocation: "Madikeri, Kodagu, Karnataka",
    desc:
        "The capital of Kodagu — home to Raja's Seat, Omkareshwara Temple, and misty viewpoints.",
    about:
        "Madikeri, also known as Mercara, is the headquarters of Kodagu district and sits at an elevation of 1,525 metres in the Western Ghats. Surrounded by mist-covered hills and lush coffee estates, the town is a blend of Kodava heritage, colonial history, and natural beauty. The winding roads leading into town through coffee and cardamom plantations set the mood for everything Coorg has to offer.",
    highlights: [
      {
        "label": "Raja's Seat",
        "icon": Icons.landscape_rounded,
        "desc": "Famous sunset viewpoint used by Coorg kings",
      },
      {
        "label": "Omkareshwara Temple",
        "icon": Icons.temple_hindu_rounded,
        "desc": "200-year-old temple with Indo-Saracenic architecture",
      },
      {
        "label": "Madikeri Fort",
        "icon": Icons.fort_rounded,
        "desc": "Historic fort built by Mudduraja in the 17th century",
      },
      {
        "label": "Abbey Falls",
        "icon": Icons.water_rounded,
        "desc": "Stunning 70ft waterfall through coffee estates",
      },
    ],
    nearbyPlaces: [
      {"name": "Abbey Falls", "dist": "8 km"},
      {"name": "Mandalpatti", "dist": "28 km"},
      {"name": "Bhagamandala", "dist": "38 km"},
    ],
    bestTime: "October to March",
    weather: "18–26°C",
    population: "~33,000",
  ),
  Town(
    name: "Virajpet",
    aka: "Virarajendrapet",
    emoji: "🌳",
    imagePath: "assets/images/virajpete.jpg",
    fullLocation: "Virajpet, Kodagu, Karnataka",
    desc:
        "Gateway to Nagarhole and Brahmagiri, rich in Kodava culture and wildlife trails.",
    about:
        "Virajpet, the second largest town in Kodagu, serves as the gateway to some of the most pristine forests and wildlife reserves in South India. The town retains a strong Kodava cultural identity, with traditional 'Ainmane' ancestral homes dotting the surrounding villages. It is the base for exploring the Brahmagiri range and the vast Nagarhole forests.",
    highlights: [
      {
        "label": "Nagarhole Park",
        "icon": Icons.forest_rounded,
        "desc": "Tiger reserve with diverse wildlife",
      },
      {
        "label": "Brahmagiri Trek",
        "icon": Icons.hiking_rounded,
        "desc": "Challenging trek through dense forest",
      },
      {
        "label": "Iruppu Falls",
        "icon": Icons.water_rounded,
        "desc": "Sacred waterfall near Brahmagiri",
      },
      {
        "label": "Kodava Culture",
        "icon": Icons.museum_rounded,
        "desc": "Traditional Kodava heritage & festivals",
      },
    ],
    nearbyPlaces: [
      {"name": "Nagarhole", "dist": "25 km"},
      {"name": "Iruppu Falls", "dist": "55 km"},
      {"name": "Gonikoppal", "dist": "20 km"},
    ],
    bestTime: "November to April",
    weather: "20–30°C",
    population: "~25,000",
  ),
  Town(
    name: "Kushalnagar",
    aka: "Little Tibet",
    emoji: "🏔️",
    imagePath: "assets/images/kushalnagara.jpg",
    fullLocation: "Kushalnagar, Kodagu, Karnataka",
    desc:
        "Home to the Tibetan settlement, golden temples, and Dubare Elephant Camp.",
    about:
        "Kushalnagar, fondly called 'Little Tibet', is home to the Namdroling Monastery — one of the largest Nyingma teaching centres in the world, famous for its stunning Golden Temple. The town sits along the Cauvery river and is the entry point to Coorg from Mysuru. The vibrant Tibetan community has brought a unique cultural layer to this part of Kodagu.",
    highlights: [
      {
        "label": "Golden Temple",
        "icon": Icons.temple_buddhist_rounded,
        "desc": "Namdroling Monastery's stunning centrepiece",
      },
      {
        "label": "Dubare Elephant Camp",
        "icon": Icons.forest_rounded,
        "desc": "Bathe & feed elephants on the Cauvery",
      },
      {
        "label": "Bylakuppe",
        "icon": Icons.location_city_rounded,
        "desc": "Largest Tibetan settlement in India",
      },
      {
        "label": "Cauvery Riverbank",
        "icon": Icons.water_rounded,
        "desc": "Scenic picnic & rafting spots",
      },
    ],
    nearbyPlaces: [
      {"name": "Dubare", "dist": "9 km"},
      {"name": "Bylakuppe", "dist": "10 km"},
      {"name": "Madikeri", "dist": "36 km"},
    ],
    bestTime: "October to February",
    weather: "18–28°C",
    population: "~15,000",
  ),
  Town(
    name: "Somwarpet",
    aka: "Coffee Town",
    emoji: "☕",
    imagePath: "assets/images/somwarpet.png",
    fullLocation: "Somwarpet, Kodagu, Karnataka",
    desc:
        "Coorg's coffee heartland — rolling estates, misty mornings, and serene village life.",
    about:
        "Somwarpet taluk is the heartbeat of Coorg's famous coffee culture. Vast plantations of arabica and robusta coffee stretch across rolling hills, and the air carries the heady fragrance of coffee blossoms in season. The town itself is quiet and unhurried, making it a favourite for those seeking an authentic, off-the-beaten-track Coorg experience away from the tourist crowd.",
    highlights: [
      {
        "label": "Coffee Estates",
        "icon": Icons.eco_rounded,
        "desc": "Guided tours of working coffee plantations",
      },
      {
        "label": "Chelavara Falls",
        "icon": Icons.water_rounded,
        "desc": "Secluded waterfall through forest trails",
      },
      {
        "label": "Harangi Reservoir",
        "icon": Icons.water_damage_rounded,
        "desc": "Scenic dam surrounded by forests",
      },
      {
        "label": "Spice Plantations",
        "icon": Icons.grass_rounded,
        "desc": "Pepper, cardamom & vanilla estates",
      },
    ],
    nearbyPlaces: [
      {"name": "Chelavara Falls", "dist": "15 km"},
      {"name": "Harangi Dam", "dist": "18 km"},
      {"name": "Madikeri", "dist": "25 km"},
    ],
    bestTime: "September to March",
    weather: "18–28°C",
    population: "~18,000",
  ),
  Town(
    name: "Gonikoppal",
    aka: "Spice Capital",
    emoji: "🌶️",
    imagePath: "assets/images/gonikoppal.jpg",
    fullLocation: "Gonikoppal, Kodagu, Karnataka",
    desc:
        "A quaint town surrounded by pepper and cardamom plantations near Iruppu Falls.",
    about:
        "Gonikoppal is a charming small town in the Virajpet taluk, best known as the spice trading hub of Coorg. The weekly market draws farmers from surrounding villages who bring fresh pepper, cardamom, and ginger. The town is also the nearest base for visiting the sacred Iruppu Falls and the Brahmagiri Wildlife Sanctuary, making it popular with nature lovers and pilgrims alike.",
    highlights: [
      {
        "label": "Spice Market",
        "icon": Icons.storefront_rounded,
        "desc": "Weekly market with fresh local spices",
      },
      {
        "label": "Iruppu Falls",
        "icon": Icons.water_rounded,
        "desc": "Sacred waterfall & Shiva temple",
      },
      {
        "label": "Brahmagiri WLS",
        "icon": Icons.forest_rounded,
        "desc": "Biodiversity hotspot on the Kerala border",
      },
      {
        "label": "Pepper Estates",
        "icon": Icons.grass_rounded,
        "desc": "Authentic spice plantation walks",
      },
    ],
    nearbyPlaces: [
      {"name": "Iruppu Falls", "dist": "32 km"},
      {"name": "Brahmagiri", "dist": "35 km"},
      {"name": "Virajpet", "dist": "20 km"},
    ],
    bestTime: "October to April",
    weather: "20–30°C",
    population: "~12,000",
  ),
];

class TownsScreen extends StatelessWidget {
  const TownsScreen({super.key});

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
                    Text(
                      "Famous Towns",
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
                      "Explore Coorg's iconic towns & villages",
                      style: TextStyle(fontSize: 14, color: textSec),
                    ),
                  ],
                ),
              ),
            ),

            // ── Towns list ───────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _TownCard(
                    town: allTowns[index],
                    isDark: isDark,
                    textPri: textPri,
                    textSec: textSec,
                  ),
                  childCount: allTowns.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Town card ─────────────────────────────────────────────
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
            // ── Image ────────────────────────────────────
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
                  // Town name on image
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
                        // Aka pill
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

            // ── Description + arrow ───────────────────────
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
