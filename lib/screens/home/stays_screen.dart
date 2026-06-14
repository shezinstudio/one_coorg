import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StaysScreen extends StatelessWidget {
  const StaysScreen({super.key});

  static const List<Map<String, dynamic>> _stays = [
    {
      "name": "Amanvana Spa Resort",
      "type": "Luxury Resort",
      "location": "Kushalnagar",
      "desc":
          "A riverside luxury resort on the Cauvery with spa, yoga, and forest views.",
      "emoji": "🏨",
      "price": "₹₹₹₹",
    },
    {
      "name": "Tamara Coorg",
      "type": "Luxury Resort",
      "location": "Yavakapadi",
      "desc":
          "Award-winning hillside resort with breathtaking coffee estate and valley views.",
      "emoji": "🌿",
      "price": "₹₹₹₹",
    },
    {
      "name": "Evolve Back Coorg",
      "type": "Heritage Resort",
      "location": "Virajpet",
      "desc":
          "Boutique eco-resort on a working coffee estate with immersive local experiences.",
      "emoji": "🍃",
      "price": "₹₹₹₹",
    },
    {
      "name": "Coorg Wilderness Resort",
      "type": "Jungle Stay",
      "location": "Galibeedu",
      "desc":
          "Treehouses and cottages deep in the forest — ideal for wildlife lovers.",
      "emoji": "🌲",
      "price": "₹₹₹",
    },
    {
      "name": "Old Kent Estate",
      "type": "Heritage Stay",
      "location": "Siddapur",
      "desc":
          "A classic colonial bungalow on a 300-acre coffee and pepper estate.",
      "emoji": "🏡",
      "price": "₹₹₹",
    },
    {
      "name": "Honey Valley Estate",
      "type": "Homestay",
      "location": "Kakkabe",
      "desc":
          "A beloved family homestay at the foothills of Tadiandamol — perfect for trekkers.",
      "emoji": "🐝",
      "price": "₹₹",
    },
  ];

  static const Map<String, Color> _typeColors = {
    "Luxury Resort": Color(0xFF6A1B9A),
    "Heritage Resort": AppColors.primaryLight,
    "Heritage Stay": AppColors.primary,
    "Jungle Stay": Color(0xFF2E7D32),
    "Homestay": Color(0xFF1565C0),
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
                    Text(
                      "Stays & Hotels",
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
                      "Find your perfect home in the hills",
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
                  final stay = _stays[index];
                  final Color typeColor =
                      _typeColors[stay["type"]] ?? AppColors.primary;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark
                          ? Border.all(color: AppColors.dividerDark)
                          : null,
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.07,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Colored top band
                        Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.75),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    stay["emoji"] as String,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stay["name"] as String,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: textPri,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: typeColor.withValues(
                                                  alpha: isDark ? 0.25 : 0.10,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                stay["type"] as String,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: typeColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.location_on_rounded,
                                              size: 11,
                                              color: textSec,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              stay["location"] as String,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: textSec,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    stay["price"] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.primaryBright
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                stay["desc"] as String,
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
                }, childCount: _stays.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
