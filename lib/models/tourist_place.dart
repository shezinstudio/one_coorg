// lib/models/tourist_place.dart
// Single unified model — replaces both TouristPlace and _placeDetails map

import 'package:flutter/material.dart';

// Maps activity label strings stored in Supabase → Flutter IconData
// Add more entries here whenever you add new activity types
const Map<String, IconData> activityIconMap = {
  "Hiking": Icons.hiking_rounded,
  "Photography": Icons.camera_alt_rounded,
  "Sightseeing": Icons.park_rounded,
  "Safari": Icons.directions_car_rounded,
  "Birdwatching": Icons.visibility_rounded,
  "Exploring": Icons.explore_rounded,
  "Sunset View": Icons.wb_twilight_rounded,
  "Gardens": Icons.local_florist_rounded,
  "Trekking": Icons.terrain_rounded,
  "Swimming": Icons.pool_rounded,
  "Camping": Icons.cabin_rounded,
  "Boating": Icons.sailing_rounded,
};

class TouristPlace {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl; // Supabase Storage public URL
  final String location;
  final String emoji;

  // Detail screen fields
  final double rating;
  final String duration;
  final String temp;
  final String entryFee;
  final bool isTopRated;
  final String fullLocation;
  final String about;
  final List<String> activities; // stored as text[] in Supabase
  final String bestTime;
  final String mapLabel;
  final double lat;
  final double lng;

  const TouristPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.location,
    required this.emoji,
    required this.rating,
    required this.duration,
    required this.temp,
    required this.entryFee,
    required this.isTopRated,
    required this.fullLocation,
    required this.about,
    required this.activities,
    required this.bestTime,
    required this.mapLabel,
    required this.lat,
    required this.lng,
  });

  // Deserialise a Supabase row into a TouristPlace
  factory TouristPlace.fromMap(Map<String, dynamic> map) {
    return TouristPlace(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      emoji: map['emoji']?.toString() ?? '📍',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      duration: map['duration']?.toString() ?? '1–2 hrs',
      temp: map['temp']?.toString() ?? '22°C',
      entryFee: map['entry_fee']?.toString() ?? 'Free',
      isTopRated: map['is_top_rated'] as bool? ?? false,
      fullLocation: map['full_location']?.toString() ?? '',
      about: map['about']?.toString() ?? '',
      // activities is a text[] column in Supabase → List<dynamic> in Dart
      activities:
          (map['activities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bestTime: map['best_time']?.toString() ?? '',
      mapLabel: map['map_label']?.toString() ?? '',
      lat: (map['lat'] as num?)?.toDouble() ?? 12.4244,
      lng: (map['lng'] as num?)?.toDouble() ?? 75.7382,
    );
  }

  // Equality by id — used by FavouritesNotifier
  @override
  bool operator ==(Object other) => other is TouristPlace && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
