// lib/services/trip_weather_service.dart
//
// Pulls a multi-day forecast from Open-Meteo (same no-API-key provider
// already used for the Home screen's weather widget) and matches it to
// trip day dates. If you already have a WeatherNotifier/WeatherService with
// its own weather-code → icon mapping, prefer wiring that in instead of the
// small local map below, so the icon language stays consistent app-wide.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DayForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMaxC;
  final double tempMinC;
  final int precipitationChance; // 0–100

  const DayForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMaxC,
    required this.tempMinC,
    required this.precipitationChance,
  });

  String get description => _weatherDescriptions[weatherCode] ?? 'Unknown';
  IconData get icon => _weatherIcons[weatherCode] ?? Icons.help_outline_rounded;
  bool get isRainy =>
      precipitationChance >= 50 || _rainyCodes.contains(weatherCode);
}

// Open-Meteo WMO weather codes, simplified to the common cases.
const Map<int, String> _weatherDescriptions = {
  0: 'Clear sky',
  1: 'Mostly clear',
  2: 'Partly cloudy',
  3: 'Overcast',
  45: 'Fog',
  48: 'Fog',
  51: 'Light drizzle',
  53: 'Drizzle',
  55: 'Dense drizzle',
  61: 'Light rain',
  63: 'Rain',
  65: 'Heavy rain',
  80: 'Rain showers',
  81: 'Rain showers',
  82: 'Violent showers',
  95: 'Thunderstorm',
};

const Map<int, IconData> _weatherIcons = {
  0: Icons.wb_sunny_rounded,
  1: Icons.wb_sunny_outlined,
  2: Icons.wb_cloudy_rounded,
  3: Icons.cloud_rounded,
  45: Icons.foggy,
  48: Icons.foggy,
  51: Icons.grain_rounded,
  53: Icons.grain_rounded,
  55: Icons.grain_rounded,
  61: Icons.water_drop_rounded,
  63: Icons.water_drop_rounded,
  65: Icons.thunderstorm_rounded,
  80: Icons.water_drop_rounded,
  81: Icons.water_drop_rounded,
  82: Icons.thunderstorm_rounded,
  95: Icons.thunderstorm_rounded,
};

const Set<int> _rainyCodes = {51, 53, 55, 61, 63, 65, 80, 81, 82, 95};

class TripWeatherService {
  /// Fetches a daily forecast covering [days] days starting today, for the
  /// given coordinates. Open-Meteo's free tier supports up to 16 days ahead;
  /// requests beyond that are clamped.
  static Future<Map<String, DayForecast>> fetchForecast({
    required double lat,
    required double lng,
    required int days,
  }) async {
    final clampedDays = days.clamp(1, 16);
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lng'
      '&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max'
      '&timezone=auto&forecast_days=$clampedDays',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Weather request failed (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final daily = body['daily'] as Map<String, dynamic>;
    final dates = (daily['time'] as List).cast<String>();
    final codes = (daily['weathercode'] as List).cast<num>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final precip =
        (daily['precipitation_probability_max'] as List?)?.cast<num>() ??
        List.filled(dates.length, 0);

    final result = <String, DayForecast>{};
    for (int i = 0; i < dates.length; i++) {
      result[dates[i]] = DayForecast(
        date: DateTime.parse(dates[i]),
        weatherCode: codes[i].toInt(),
        tempMaxC: maxTemps[i].toDouble(),
        tempMinC: minTemps[i].toDouble(),
        precipitationChance: precip[i].toInt(),
      );
    }
    return result;
  }
}

// Format a DateTime as Open-Meteo's yyyy-MM-dd key, used to look up a day's
// forecast in the map returned above.
String forecastKeyFor(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
