// lib/services/trip_planner_service.dart
//
// Generates a day-by-day itinerary from a flat list of selected places by
// clustering them geographically (k-means over lat/lng, using
// Geolocator.distanceBetween for distance) so each day's stops sit close
// together, then ordering days and stops-within-a-day to minimise
// backtracking. Also estimates each day's total driving distance/time and,
// if a start date is supplied, stamps each day with a real calendar date.

import 'package:geolocator/geolocator.dart';
import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/models/trip_plan.dart';

// Reference point used to decide which cluster/day should come "first" —
// same coordinates already used for your fixed-location weather widget.
const double _madikeriLat = 12.4244;
const double _madikeriLng = 75.7382;

// Coorg's roads are hilly and winding — this is a deliberately conservative
// average to avoid under-promising on drive time. Tune as needed.
const double _avgSpeedKmh = 28.0;

class _Point {
  final double lat;
  final double lng;
  const _Point(this.lat, this.lng);
}

class TripPlannerService {
  /// Builds a [TripPlan] from [places] spread across [requestedDays].
  ///
  /// If there are more days than places, the surplus days come back with an
  /// empty place list (the UI can render these as "free days"). If there are
  /// more places than days, every day gets at least one place, with places
  /// grouped by physical proximity. If [startDate] is provided, each
  /// [TripDay.date] is stamped accordingly (day 1 = startDate).
  static TripPlan generate({
    required List<TouristPlace> places,
    required int requestedDays,
    DateTime? startDate,
    String title = 'New Trip',
  }) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final createdAt = DateTime.now();

    if (places.isEmpty || requestedDays <= 0) {
      return TripPlan(
        id: id,
        title: title,
        createdAt: createdAt,
        startDate: startDate,
        days: const [],
      );
    }

    final int effectiveDays = requestedDays > places.length
        ? places.length
        : requestedDays;

    final List<TouristPlace> seeds = _farthestPointSeeds(places, effectiveDays);
    List<_Point> centroids = seeds.map((p) => _Point(p.lat, p.lng)).toList();

    List<List<TouristPlace>> clusters = List.generate(
      effectiveDays,
      (_) => <TouristPlace>[],
    );

    // Lloyd's algorithm — a handful of iterations is plenty at this scale
    // (a trip is at most a few dozen places).
    for (int iteration = 0; iteration < 10; iteration++) {
      clusters = List.generate(effectiveDays, (_) => <TouristPlace>[]);

      for (final place in places) {
        int nearestIndex = 0;
        double nearestDist = double.infinity;
        for (int c = 0; c < centroids.length; c++) {
          final dist = Geolocator.distanceBetween(
            place.lat,
            place.lng,
            centroids[c].lat,
            centroids[c].lng,
          );
          if (dist < nearestDist) {
            nearestDist = dist;
            nearestIndex = c;
          }
        }
        clusters[nearestIndex].add(place);
      }

      for (int c = 0; c < clusters.length; c++) {
        if (clusters[c].isEmpty) continue;
        final avgLat =
            clusters[c].map((p) => p.lat).reduce((a, b) => a + b) /
            clusters[c].length;
        final avgLng =
            clusters[c].map((p) => p.lng).reduce((a, b) => a + b) /
            clusters[c].length;
        centroids[c] = _Point(avgLat, avgLng);
      }
    }

    final orderedClusters = _orderClustersGeographically(clusters, centroids);

    final days = <TripDay>[];
    for (int i = 0; i < orderedClusters.length; i++) {
      final orderedPlaces = _orderPlacesWithinDay(orderedClusters[i]);
      final metrics = _dayMetrics(orderedPlaces);
      days.add(
        TripDay(
          dayNumber: i + 1,
          places: orderedPlaces,
          date: startDate?.add(Duration(days: i)),
          distanceKm: metrics.$1,
          driveMinutes: metrics.$2,
        ),
      );
    }

    // Pad with empty "free day" entries if the user asked for more days
    // than there were places to fill them with.
    for (int i = orderedClusters.length; i < requestedDays; i++) {
      days.add(
        TripDay(
          dayNumber: i + 1,
          places: const [],
          date: startDate?.add(Duration(days: i)),
        ),
      );
    }

    return TripPlan(
      id: id,
      title: title,
      createdAt: createdAt,
      startDate: startDate,
      days: days,
    );
  }

  /// Total driving distance (km) and rough drive time (minutes) to link an
  /// already-ordered list of stops in sequence, using the same
  /// straight-line distance approach as the clustering above (a reasonable
  /// approximation for a small region like Kodagu, and consistent with what
  /// "Nearby" already uses).
  static (double, int) _dayMetrics(List<TouristPlace> orderedPlaces) {
    if (orderedPlaces.length < 2) return (0, 0);
    double totalMeters = 0;
    for (int i = 0; i < orderedPlaces.length - 1; i++) {
      totalMeters += Geolocator.distanceBetween(
        orderedPlaces[i].lat,
        orderedPlaces[i].lng,
        orderedPlaces[i + 1].lat,
        orderedPlaces[i + 1].lng,
      );
    }
    final km = totalMeters / 1000;
    final minutes = ((km / _avgSpeedKmh) * 60).round();
    return (km, minutes);
  }

  /// Farthest-point sampling: start from the place closest to Madikeri, then
  /// repeatedly add whichever remaining place is farthest from every point
  /// already chosen. This spreads the initial centroids out across the
  /// selected places instead of risking several seeds landing near each
  /// other (which is the usual cause of empty k-means clusters).
  static List<TouristPlace> _farthestPointSeeds(
    List<TouristPlace> places,
    int k,
  ) {
    final remaining = List<TouristPlace>.from(places);
    final chosen = <TouristPlace>[];

    remaining.sort(
      (a, b) =>
          Geolocator.distanceBetween(
            _madikeriLat,
            _madikeriLng,
            a.lat,
            a.lng,
          ).compareTo(
            Geolocator.distanceBetween(
              _madikeriLat,
              _madikeriLng,
              b.lat,
              b.lng,
            ),
          ),
    );
    chosen.add(remaining.removeAt(0));

    while (chosen.length < k && remaining.isNotEmpty) {
      TouristPlace? best;
      double bestMinDist = -1;
      for (final candidate in remaining) {
        double minDistToChosen = double.infinity;
        for (final c in chosen) {
          final d = Geolocator.distanceBetween(
            candidate.lat,
            candidate.lng,
            c.lat,
            c.lng,
          );
          if (d < minDistToChosen) minDistToChosen = d;
        }
        if (minDistToChosen > bestMinDist) {
          bestMinDist = minDistToChosen;
          best = candidate;
        }
      }
      chosen.add(best!);
      remaining.remove(best);
    }

    return chosen;
  }

  /// Orders clusters via a nearest-neighbour chain starting from whichever
  /// cluster's centroid sits closest to Madikeri — so the itinerary reads
  /// as a sensible geographic progression rather than a random day order.
  static List<List<TouristPlace>> _orderClustersGeographically(
    List<List<TouristPlace>> clusters,
    List<_Point> centroids,
  ) {
    final indices = List<int>.generate(clusters.length, (i) => i);
    if (indices.isEmpty) return [];

    indices.sort(
      (a, b) =>
          Geolocator.distanceBetween(
            _madikeriLat,
            _madikeriLng,
            centroids[a].lat,
            centroids[a].lng,
          ).compareTo(
            Geolocator.distanceBetween(
              _madikeriLat,
              _madikeriLng,
              centroids[b].lat,
              centroids[b].lng,
            ),
          ),
    );

    final ordered = <int>[indices.removeAt(0)];
    while (indices.isNotEmpty) {
      final last = centroids[ordered.last];
      indices.sort(
        (a, b) =>
            Geolocator.distanceBetween(
              last.lat,
              last.lng,
              centroids[a].lat,
              centroids[a].lng,
            ).compareTo(
              Geolocator.distanceBetween(
                last.lat,
                last.lng,
                centroids[b].lat,
                centroids[b].lng,
              ),
            ),
      );
      ordered.add(indices.removeAt(0));
    }

    return ordered.map((i) => clusters[i]).toList();
  }

  /// Greedy nearest-neighbour path through a single day's places, starting
  /// from whichever stop is closest to Madikeri.
  static List<TouristPlace> _orderPlacesWithinDay(List<TouristPlace> day) {
    if (day.length <= 1) return day;

    final remaining = List<TouristPlace>.from(day);
    remaining.sort(
      (a, b) =>
          Geolocator.distanceBetween(
            _madikeriLat,
            _madikeriLng,
            a.lat,
            a.lng,
          ).compareTo(
            Geolocator.distanceBetween(
              _madikeriLat,
              _madikeriLng,
              b.lat,
              b.lng,
            ),
          ),
    );

    final ordered = <TouristPlace>[remaining.removeAt(0)];
    while (remaining.isNotEmpty) {
      final last = ordered.last;
      remaining.sort(
        (a, b) => Geolocator.distanceBetween(last.lat, last.lng, a.lat, a.lng)
            .compareTo(
              Geolocator.distanceBetween(last.lat, last.lng, b.lat, b.lng),
            ),
      );
      ordered.add(remaining.removeAt(0));
    }

    return ordered;
  }

  /// Recomputes distance/time for a day after a manual drag-and-drop edit —
  /// call this whenever the UI reorders or moves places between days so the
  /// displayed metrics stay accurate.
  static TripDay recomputeDayMetrics(TripDay day) {
    final metrics = _dayMetrics(day.places);
    return day.copyWith(distanceKm: metrics.$1, driveMinutes: metrics.$2);
  }
}
