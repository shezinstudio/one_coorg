import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/screens/home/place_detail_screen.dart';
import 'package:one_coorg/services/place_service.dart';
import 'package:one_coorg/theme/app_colors.dart';

class PlaceOfTheDay extends StatefulWidget {
  const PlaceOfTheDay({super.key});

  @override
  State<PlaceOfTheDay> createState() => _PlaceOfTheDayState();
}

class _PlaceOfTheDayState extends State<PlaceOfTheDay> {
  List<TouristPlace> _places = [];
  TouristPlace? _current;
  Timer? _timer;
  bool _loading = true;
  bool _error = false;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await PlaceService.fetchPlaces();
      if (!mounted) return;
      setState(() {
        _places = places;
        _current = places.isNotEmpty
            ? places[_rand.nextInt(places.length)]
            : null;
        _loading = false;
      });
      _startRotation();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void _startRotation() {
    _timer?.cancel();
    if (_places.length <= 1) return; // nothing to rotate between
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {
        // avoid repeating the same place twice in a row
        TouristPlace next;
        do {
          next = _places[_rand.nextInt(_places.length)];
        } while (_places.length > 1 && next.id == _current?.id);
        _current = next;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.cardLight,
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    if (_error || _current == null) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.cardLight,
        ),
        child: Center(
          child: Text(
            _error ? "Couldn't load place of the day" : "No places found",
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final place = _current!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(place.id), // triggers the fade when place changes
        height: 220,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            // ── Image ──────────────────────────────────
            Positioned.fill(
              child: Image.network(
                place.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.cardLight,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Colors.black38,
                    ),
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.cardLight,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),

            // ── Gradient overlay ───────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // ── Content ────────────────────────────────
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EXPLORE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          place.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlaceDetailScreen(place: place),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Explore Now'),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
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
