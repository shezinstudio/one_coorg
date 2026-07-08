// lib/models/trip_plan.dart

import 'package:one_coorg/models/tourist_place.dart';

/// A single day within a generated trip, holding an ordered list of stops.
class TripDay {
  final int dayNumber;
  final List<TouristPlace> places;
  final DateTime? date; // null if the trip has no start date set
  final double distanceKm; // total driving distance linking this day's stops
  final int driveMinutes; // rough estimate, see _avgSpeedKmh in the service

  const TripDay({
    required this.dayNumber,
    required this.places,
    this.date,
    this.distanceKm = 0,
    this.driveMinutes = 0,
  });

  bool get isEmpty => places.isEmpty;

  TripDay copyWith({
    int? dayNumber,
    List<TouristPlace>? places,
    DateTime? date,
    double? distanceKm,
    int? driveMinutes,
  }) {
    return TripDay(
      dayNumber: dayNumber ?? this.dayNumber,
      places: places ?? this.places,
      date: date ?? this.date,
      distanceKm: distanceKm ?? this.distanceKm,
      driveMinutes: driveMinutes ?? this.driveMinutes,
    );
  }

  Map<String, dynamic> toMap() => {
    'day_number': dayNumber,
    'date': date?.toIso8601String(),
    'distance_km': distanceKm,
    'drive_minutes': driveMinutes,
    'places': places.map(_placeToMap).toList(),
  };

  factory TripDay.fromMap(Map<String, dynamic> map) {
    return TripDay(
      dayNumber: map['day_number'] as int? ?? 1,
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      distanceKm: (map['distance_km'] as num?)?.toDouble() ?? 0,
      driveMinutes: map['drive_minutes'] as int? ?? 0,
      places:
          (map['places'] as List<dynamic>?)
              ?.map((m) => TouristPlace.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// A saved or in-progress itinerary — a list of [TripDay]s in visiting order.
class TripPlan {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? startDate;
  final List<TripDay> days;

  const TripPlan({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.days,
    this.startDate,
  });

  bool get isEmpty => days.isEmpty;
  int get totalPlaces => days.fold(0, (sum, d) => sum + d.places.length);

  TripPlan copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? startDate,
    List<TripDay>? days,
  }) {
    return TripPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      days: days ?? this.days,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'created_at': createdAt.toIso8601String(),
    'start_date': startDate?.toIso8601String(),
    'days': days.map((d) => d.toMap()).toList(),
  };

  factory TripPlan.fromMap(Map<String, dynamic> map) {
    return TripPlan(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled Trip',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      startDate: map['start_date'] != null
          ? DateTime.tryParse(map['start_date'])
          : null,
      days:
          (map['days'] as List<dynamic>?)
              ?.map((m) => TripDay.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// Mirrors FavouritesNotifier's _toMap — converts a TouristPlace back to a
// map that TouristPlace.fromMap() can read, so saved trips can be fully
// reconstructed offline without refetching from Supabase.
Map<String, dynamic> _placeToMap(TouristPlace p) => {
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
  'is_family_friendly': p.isFamilyFriendly,
  'is_adventure': p.isAdventure,
};
