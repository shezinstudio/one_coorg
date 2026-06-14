// lib/services/place_service.dart

import 'package:one_coorg/models/tourist_place.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaceService {
  static final _db = Supabase.instance.client;

  // ── Fetch all places, optionally filtered by category ───
  static Future<List<TouristPlace>> fetchPlaces({String? category}) async {
    var query = _db.from('places').select().order('name', ascending: true);

    // category filter is applied after fetch to keep code simple;
    // for large datasets move the .eq() into the query builder
    final List<dynamic> rows = await query;

    final places = rows
        .map((row) => TouristPlace.fromMap(row as Map<String, dynamic>))
        .toList();

    if (category == null || category == 'All') return places;
    return places.where((p) => p.category == category).toList();
  }

  // ── Fetch a single place by id (for detail screen refresh) ─
  static Future<TouristPlace> fetchPlaceById(String id) async {
    final row = await _db.from('places').select().eq('id', id).single();
    return TouristPlace.fromMap(row);
  }
}
