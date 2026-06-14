// lib/providers/favourites_provider.dart

import 'dart:convert';
import 'package:one_coorg/models/tourist_place.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesNotifier extends ChangeNotifier {
  static const _idsKey = 'favourite_place_ids';

  final List<TouristPlace> _favourites = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<TouristPlace> get favourites => List.unmodifiable(_favourites);

  FavouritesNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_idsKey) ?? [];

    for (final id in ids) {
      final raw = prefs.getString('fav_$id');
      if (raw != null) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          _favourites.add(TouristPlace.fromMap(map));
        } catch (_) {
          /* skip corrupted entry */
        }
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_idsKey, _favourites.map((p) => p.id).toList());
    for (final p in _favourites) {
      await prefs.setString('fav_${p.id}', jsonEncode(_toMap(p)));
    }
  }

  bool isFavourite(TouristPlace place) =>
      _favourites.any((p) => p.id == place.id);

  void toggle(TouristPlace place) {
    if (isFavourite(place)) {
      _favourites.removeWhere((p) => p.id == place.id);
      SharedPreferences.getInstance().then(
        (prefs) => prefs.remove('fav_${place.id}'),
      );
    } else {
      _favourites.add(place);
    }
    notifyListeners();
    _save();
  }

  // Convert TouristPlace back to a map that TouristPlace.fromMap() can read
  Map<String, dynamic> _toMap(TouristPlace p) => {
    'id': p.id,
    'name': p.name,
    'description': p.description,
    'category': p.category,
    'image_url': p.imageUrl,
    'location': p.location,
    'emoji': p.emoji,
    'rating': p.rating,
    'duration': p.duration,
    'temp': p.temp,
    'entry_fee': p.entryFee,
    'is_top_rated': p.isTopRated,
    'full_location': p.fullLocation,
    'about': p.about,
    'activities': p.activities,
    'best_time': p.bestTime,
    'map_label': p.mapLabel,
    'lat': p.lat,
    'lng': p.lng,
  };
}

class FavouritesProvider extends InheritedNotifier<FavouritesNotifier> {
  const FavouritesProvider({
    super.key,
    required FavouritesNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static FavouritesNotifier of(BuildContext context) {
    final p = context.dependOnInheritedWidgetOfExactType<FavouritesProvider>();
    assert(p != null, 'No FavouritesProvider found in widget tree');
    return p!.notifier!;
  }
}
