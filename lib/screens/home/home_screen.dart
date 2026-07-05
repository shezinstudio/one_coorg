import 'package:flutter/material.dart';
import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/screens/home/hidden_gem_screen.dart';
import 'package:one_coorg/screens/home/towns_screen.dart';
import 'package:one_coorg/services/place_service.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:one_coorg/widgets/banner_ad_widget.dart';
import 'package:one_coorg/widgets/category_item.dart';
import 'package:one_coorg/widgets/place_of_the_day.dart';
import 'package:one_coorg/widgets/towns_home_section.dart';
import 'package:one_coorg/widgets/weather_status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<TouristPlace>> _hiddenGemsFuture;

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

                    // Search bar
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 16,
                    //     vertical: 12,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: inputBg,
                    //     borderRadius: BorderRadius.circular(16),
                    //     border: Border.all(color: divider),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: AppColors.primary.withValues(alpha: 0.06),
                    //         blurRadius: 12,
                    //         offset: const Offset(0, 3),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       // location icon
                    //       Icon(
                    //         Icons.location_pin,
                    //         color: AppColors.primaryLight,
                    //         size: 20,
                    //       ),
                    //       const SizedBox(width: 5),
                    //       // Madikeri, Coorg text
                    //       const Text(
                    //         "Madikeri, Coorg",
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           color: AppColors.textSecondaryLight,
                    //         ),
                    //       ),
                    //       const Spacer(),
                    //       // weather details
                    //       Icon(
                    //         Icons.cloud_outlined,
                    //         color: AppColors.primaryLight,
                    //         size: 20,
                    //       ),
                    //       const SizedBox(width: 5),
                    //       const Text(
                    //         "24C  - Sunny",
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           color: AppColors.textSecondaryLight,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // place of  the day=============================================
                    //const SizedBox(height: 20),

                    //                     Container(
                    //                       height: 220,
                    //                       width: double.infinity,
                    //                       decoration: BoxDecoration(
                    //                         borderRadius: BorderRadius.circular(20),
                    //                         image: const DecorationImage(
                    //                           image: AssetImage("assets/images/abbey_falls.jpg"),
                    //                           //// or AssetImage
                    //                           fit: BoxFit.cover,
                    //                         ),
                    //                       ),
                    //                       child: Container(
                    //                         // dark gradient overlay so text is readable
                    //                         decoration: BoxDecoration(
                    //                           borderRadius: BorderRadius.circular(20),
                    //                           gradient: LinearGradient(
                    //                             begin: Alignment.topCenter,
                    //                             end: Alignment.bottomCenter,
                    //                             colors: [
                    //                               Colors.black.withValues(alpha: 0.5),
                    //                               Colors.black.withValues(alpha: 0.1),
                    //                               Colors.black.withValues(alpha: 0.6),
                    //                             ],
                    //                             stops: const [0.0, 0.4, 1.0],
                    //                           ),
                    //                         ),
                    //                         padding: const EdgeInsets.all(20),
                    //                         child: Column(
                    //                           crossAxisAlignment: CrossAxisAlignment.start,
                    //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                           children: [
                    //                             const Text(
                    //                               'EXPLORE',
                    //                               style: TextStyle(
                    //                                 color: Colors.white,
                    //                                 fontSize: 12,
                    //                                 fontWeight: FontWeight.w600,
                    //                                 letterSpacing: 1.5,
                    //                               ),
                    //                             ),
                    //                             Column(
                    //                               crossAxisAlignment: CrossAxisAlignment.start,
                    //                               children: [
                    //                                 const Text(
                    //                                   'Abbey Falls',
                    //                                   style: TextStyle(
                    //                                     color: Colors.white,
                    //                                     fontSize: 26,
                    //                                     fontWeight: FontWeight.bold,
                    //                                   ),
                    //                                 ),
                    //                                 const SizedBox(height: 6),
                    //                                 const Text(
                    //                                   'Beautiful waterfall surrounded\nby lush green nature.',
                    //                                   style: TextStyle(
                    //                                     color: Colors.white,
                    //                                     fontSize: 14,
                    //                                     height: 1.3,
                    //                                   ),
                    //                                 ),
                    //                                 const SizedBox(height: 14),
                    //                                 ElevatedButton(
                    //                                   onPressed: () {},
                    //                                   style: ElevatedButton.styleFrom(
                    //                                     backgroundColor:
                    //                                         AppColors.primary, // dark green
                    //                                     foregroundColor: Colors.white,
                    //                                     padding: const EdgeInsets.symmetric(
                    //                                       horizontal: 18,
                    //                                       vertical: 10,
                    //                                     ),
                    //                                     shape: RoundedRectangleBorder(
                    //                                       borderRadius: BorderRadius.circular(30),
                    //                                     ),
                    //                                   ),
                    //                                   child: const Row(
                    //                                     mainAxisSize: MainAxisSize.min,
                    //                                     children: [
                    //                                       Text('Explore Now'),
                    //                                       SizedBox(width: 6),
                    //                                       Icon(Icons.arrow_forward, size: 16),
                    //                                     ],
                    //                                   ),
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                           ],
                    //                         ),
                    //                       ),
                    //                     ),
                    // //

                    // place of  the day=============================================
                    const SizedBox(height: 20),

                    const PlaceOfTheDay(),

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
                            // TextButton(
                            //   onPressed: () {},
                            //   style: TextButton.styleFrom(
                            //     padding: EdgeInsets.zero,
                            //     minimumSize: Size.zero,
                            //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            //   ),
                            //   child: const Text(
                            //     'View all',
                            //     style: TextStyle(
                            //       color: Colors.green,
                            //       fontWeight: FontWeight.w600,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Horizontal scrollable category list
                        SizedBox(
                          height: 90,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              CategoryItem(emoji: '🌊', label: 'Waterfalls'),
                              CategoryItem(emoji: '🔥', label: 'Viewpoints'),
                              CategoryItem(emoji: '🐐', label: 'Wildlife'),
                              CategoryItem(emoji: '🏯', label: 'Temples'),
                              CategoryItem(emoji: '🌱', label: 'Coffee'),
                            ],
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
                                  return _DestinationItem(
                                    imageUrl: places[index].imageUrl,
                                    label: places[index].name,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        // SizedBox(
                        //   height: 180,
                        //   child: ListView.builder(
                        //     scrollDirection: Axis.horizontal,
                        //     itemCount: destinations.length,
                        //     itemBuilder: (context, index) {
                        //       return _DestinationItem(
                        //         imageUrl: destinations[index].imageUrl,
                        //         label: destinations[index].label,
                        //       );
                        //     },
                        //   ),
                        // ),

                        // Horizontal scrollable hidden gem list
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
