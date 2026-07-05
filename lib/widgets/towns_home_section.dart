import 'package:flutter/material.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:one_coorg/screens/home/towns_screen.dart'; // Town, TownsRepository
import 'package:one_coorg/screens/home/town_detail_screen.dart';

class TownsHomeSection extends StatefulWidget {
  const TownsHomeSection({super.key});

  @override
  State<TownsHomeSection> createState() => _TownsHomeSectionState();
}

class _TownsHomeSectionState extends State<TownsHomeSection> {
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
    final Color textPri = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color textSec = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return FutureBuilder<List<Town>>(
      future: _townsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // fail silently on home screen
        }

        final towns = snapshot.data!;

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: towns.length,
            itemBuilder: (context, index) {
              final town = towns[index];
              return _TownMiniCard(
                town: town,
                isDark: isDark,
                textPri: textPri,
                textSec: textSec,
              );
            },
          ),
        );
      },
    );
  }
}

class _TownMiniCard extends StatelessWidget {
  final Town town;
  final bool isDark;
  final Color textPri;
  final Color textSec;

  const _TownMiniCard({
    required this.town,
    required this.isDark,
    required this.textPri,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TownDetailScreen(town: town)),
      ),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 150,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                town.imagePath,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 110,
                  color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
                  child: Center(
                    child: Text(
                      town.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    town.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    town.aka,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: textSec),
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
