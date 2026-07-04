import 'package:flutter/material.dart';

class WeatherData {
  final double tempC;
  final String condition; // human-readable
  final IconData icon;

  WeatherData({
    required this.tempC,
    required this.condition,
    required this.icon,
  });

  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json) {
    final current = json['current'];
    final code = current['weather_code'] as int;
    final mapped = _mapWeatherCode(code);
    return WeatherData(
      tempC: (current['temperature_2m'] as num).toDouble(),
      condition: mapped.$1,
      icon: mapped.$2,
    );
  }

  // Open-Meteo uses WMO weather codes
  static (String, IconData) _mapWeatherCode(int code) {
    if (code == 0) return ('Sunny', Icons.wb_sunny_outlined);
    if (code <= 2) return ('Partly Cloudy', Icons.wb_cloudy_outlined);
    if (code == 3) return ('Cloudy', Icons.cloud_outlined);
    if (code >= 51 && code <= 67) return ('Drizzle', Icons.grain);
    if (code >= 61 && code <= 82) return ('Rain', Icons.umbrella_outlined);
    if (code >= 95) return ('Thunderstorm', Icons.thunderstorm_outlined);
    return ('Cloudy', Icons.cloud_outlined);
  }
}
