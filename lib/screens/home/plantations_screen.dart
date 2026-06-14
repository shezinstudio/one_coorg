import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PlantationsScreen extends StatelessWidget {
  const PlantationsScreen({super.key});

  static const List<Map<String, dynamic>> _plantations = [
    {
      "name": "Tata Coffee Plantation",
      "type": "Coffee",
      "location": "Pollibetta",
      "desc":
          "One of Asia's largest coffee estates — guided tours through arabica and robusta crops.",
      "emoji": "☕",
    },
    {
      "name": "Coorg Cardamom Estate",
      "type": "Spice",
      "location": "Virajpet",
      "desc":
          "Walk through rows of cardamom plants and learn the ancient art of spice harvesting.",
      "emoji": "🌱",
    },
    {
      "name": "Bittangala Pepper Estate",
      "type": "Pepper",
      "location": "Somwarpet",
      "desc":
          "A family-run estate offering an authentic look at how black pepper is grown.",
      "emoji": "🫚",
    },
    {
      "name": "Dubare Forest Reserve",
      "type": "Eco Experience",
      "location": "Kushalnagar",
      "desc":
          "A unique forest experience combining wildlife, the Cauvery river, and jungle walks.",
      "emoji": "🌲",
    },
    {
      "name": "Kailas Estate",
      "type": "Coffee & Spice",
      "location": "Siddapur",
      "desc":
          "A working Kodava family estate welcoming visitors for plantation walks and tastings.",
      "emoji": "🍃",
    },
    {
      "name": "Madikeri Coffee Plantation",
      "type": "Coffee",
      "location": "Madikeri",
      "desc":
          "Great for first-time visitors wanting to understand Coorg's rich coffee culture.",
      "emoji": "☕",
    },
  ];

  static const Map<String, Color> _typeColors = {
    "Coffee": Color(0xFF5D4037),
    "Spice": AppColors.primaryLight,
    "Pepper": Color(0xFF37474F),
    "Eco Experience": AppColors.primary,
    "Coffee & Spice": Color(0xFF6D4C41),
  };

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
    // ignore: unused_local_variable
    final Color divider = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;

    return Container(
      color: bg,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Plantation\n",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: textPri,
                              letterSpacing: -1,
                              height: 1.1,
                            ),
                          ),
                          TextSpan(
                            text: "Visits",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary,
                              letterSpacing: -1,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Coffee, spice & estate experiences",
                      style: TextStyle(fontSize: 14, color: textSec),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final p = _plantations[index];
                  final Color typeColor =
                      _typeColors[p["type"]] ?? AppColors.primary;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : typeColor.withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.06,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji badge
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: typeColor.withValues(
                              alpha: isDark ? 0.2 : 0.10,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: typeColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p["emoji"] as String,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p["name"] as String,
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: typeColor.withValues(
                                        alpha: isDark ? 0.25 : 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      p["type"] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: typeColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 11,
                                    color: textSec,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    p["location"] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSec,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Text(
                                p["desc"] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSec,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: _plantations.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
