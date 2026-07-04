import 'package:one_coorg/screens/home/about_screen.dart';
import 'package:one_coorg/screens/home/explore_screen.dart';
import 'package:one_coorg/screens/home/favourites_screen.dart';
import 'package:one_coorg/screens/home/home_screen.dart';
import 'package:one_coorg/screens/home/towns_screen.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),

    ExploreScreen(),
    TownsScreen(),
    FavouritesScreen(),

    AboutScreen(),
  ];

  final List<_NavItemData> _navItems = const [
    _NavItemData(icon: Icons.home_rounded, label: "Home"),

    _NavItemData(icon: Icons.terrain_rounded, label: "Explore"),
    _NavItemData(icon: Icons.location_city_rounded, label: "Towns"),
    _NavItemData(icon: Icons.favorite_rounded, label: "Favourites"),
    _NavItemData(icon: Icons.info_rounded, label: "About"),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _BottomNav(
        items: _navItems,
        currentIndex: _currentIndex,
        isDark: isDark,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}

// ── Custom bottom nav ─────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final List<_NavItemData> items;
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.items,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color navBg = isDark ? AppColors.surfaceDark : Colors.white;
    final Color activeBg = isDark
        ? AppColors.primary.withValues(alpha: 0.30)
        : AppColors.cardLight;
    final Color activeBdr = isDark
        ? AppColors.primaryBright.withValues(alpha: 0.25)
        : AppColors.dividerLight;
    final Color activeClr = isDark
        ? AppColors.primaryBright
        : AppColors.primary;
    final Color inactiveClr = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final bool isActive = index == currentIndex;
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 16 : 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? activeBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: isActive ? Border.all(color: activeBdr) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: isActive ? activeClr : inactiveClr,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        child: isActive
                            ? Row(
                                children: [
                                  const SizedBox(width: 7),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      color: activeClr,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
