// lib/providers/weather_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final double tempC;
  final String condition;
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

class WeatherNotifier extends ChangeNotifier {
  // Madikeri, Kodagu coordinates
  static const double _lat = 12.4244;
  static const double _lon = 75.7382;

  WeatherData? _weather;
  bool _isLoading = false;
  String? _error;

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WeatherNotifier() {
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$_lat&longitude=$_lon'
        '&current=temperature_2m,weather_code'
        '&timezone=auto',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _weather = WeatherData.fromOpenMeteo(json);
      } else {
        _error = 'Failed to load weather';
      }
    } catch (e) {
      _error = 'Could not fetch weather';
    }

    _isLoading = false;
    notifyListeners();
  }
}

class WeatherProvider extends InheritedNotifier<WeatherNotifier> {
  const WeatherProvider({
    super.key,
    required WeatherNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static WeatherNotifier of(BuildContext context) {
    final p = context.dependOnInheritedWidgetOfExactType<WeatherProvider>();
    assert(p != null, 'No WeatherProvider found in widget tree');
    return p!.notifier!;
  }
}
