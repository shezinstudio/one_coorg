import 'package:flutter/material.dart';
import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/screens/home/explore_screen.dart';
import 'package:one_coorg/screens/home/hidden_gem_screen.dart';
import 'package:one_coorg/screens/home/place_detail_screen.dart';
import 'package:one_coorg/screens/home/tour_booking_screen.dart';
import 'package:one_coorg/screens/home/towns_screen.dart';
import 'package:one_coorg/services/place_service.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:one_coorg/widgets/banner_ad_widget.dart';
import 'package:one_coorg/widgets/category_square_item.dart';
import 'package:one_coorg/widgets/place_of_the_day.dart';
import 'package:one_coorg/widgets/taxi_home_section.dart';
import 'package:one_coorg/widgets/towns_home_section.dart';
import 'package:one_coorg/widgets/weather_status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _CategoryData {
  final String label;
  final String imageUrl;
  final String filterKey;

  const _CategoryData({
    required this.label,
    required this.imageUrl,
    required this.filterKey,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<TouristPlace>> _hiddenGemsFuture;

  // TODO: swap these placeholder URLs for your own Supabase Storage /
  // asset images per category (e.g. assets/images/categories/waterfalls.jpg).
  static const List<_CategoryData> _categories = [
    _CategoryData(
      label: 'Waterfalls',
      filterKey: 'Waterfalls',
      imageUrl:
          'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=200&q=60',
    ),
    _CategoryData(
      label: 'Temples',
      filterKey: 'Temples',
      imageUrl:
          'https://wacayfyuuugawcwzsqcn.supabase.co/storage/v1/object/public/place-images/omkareshwara.jpg?w=200&q=60',
    ),
    _CategoryData(
      label: 'Viewpoints',
      filterKey: 'Viewpoints',
      imageUrl:
          'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?w=200&q=60',
    ),
    _CategoryData(
      label: 'Heritage',
      filterKey: 'Heritage',
      imageUrl:
          'https://images.unsplash.com/photo-1548013146-72479768bada?w=200&q=60',
    ),
    _CategoryData(
      label: 'Reservoirs',
      filterKey: 'Reservoirs',
      imageUrl:
          'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=200&q=60',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _hiddenGemsFuture = PlaceService.fetchHiddenGems(limit: 10);
  }

  @override
  Widget build(BuildContext context) {
    // color codes for the current page as per the theme (dark/light)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final Color textPri = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    // ui starts
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

                    const WeatherStatus(),

                    // place of  the day=============================================
                    const SizedBox(height: 20),

                    const PlaceOfTheDay(),

                    // taxi --------------------------------------------------
                    const SizedBox(height: 16),
                    TaxiHomeSection(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TourBookingScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ==========END of  place of  the day=============================================
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: title + "View all"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Popular Categories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPri,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Horizontal scrollable category list — square image
                        // tiles with the label below, on a green card.
                        SizedBox(
                          height: 78,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              return CategorySquareItem(
                                imageUrl: category.imageUrl,
                                label: category.label,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExploreScreen(
                                      initialCategory: category.filterKey,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // hidden gems
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: title + "View all"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hidden Gems',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPri,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HiddenGemScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View all',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // hiden gems list
                        SizedBox(
                          height: 180,
                          child: FutureBuilder<List<TouristPlace>>(
                            future: _hiddenGemsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Failed to load: ${snapshot.error}',
                                  ),
                                );
                              }
                              final places = snapshot.data ?? [];
                              if (places.isEmpty) {
                                return const Center(
                                  child: Text('No hidden gems yet'),
                                );
                              }
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: places.length,
                                itemBuilder: (context, index) {
                                  final place = places[index];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PlaceDetailScreen(place: place),
                                      ),
                                    ),
                                    child: _DestinationItem(
                                      imageUrl: place.imageUrl,
                                      label: place.name,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // famous towns ============================================================
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Famous Towns',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPri,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TownsScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View all',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // List of famous towns (horizontal scrollable) — just the list, no sliver wrapper
                        const TownsHomeSection(),
                      ],
                    ),
                    //  ============================================================
                    const SizedBox(height: 16),
                    // banner ad test
                    const BannerAdWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationItem extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _DestinationItem({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 150,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
