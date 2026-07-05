// lib/models/trip_plan.dart

import 'package:one_coorg/models/tourist_place.dart';

/// A single day within a generated trip, holding an ordered list of stops.
class TripDay {
  final int dayNumber;
  final List<TouristPlace> places;

  const TripDay({required this.dayNumber, required this.places});

  bool get isEmpty => places.isEmpty;
}

/// The full generated itinerary — a list of [TripDay]s in visiting order.
class TripPlan {
  final List<TripDay> days;

  const TripPlan(this.days);

  bool get isEmpty => days.isEmpty;
  int get totalPlaces => days.fold(0, (sum, d) => sum + d.places.length);
}
