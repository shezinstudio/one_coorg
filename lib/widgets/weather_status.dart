import 'package:flutter/material.dart';
import 'package:one_coorg/providers/weather_provider.dart';
import 'package:one_coorg/theme/app_colors.dart';

class WeatherStatus extends StatelessWidget {
  const WeatherStatus({super.key});

  @override
  Widget build(BuildContext context) {
    // color codes for the current page as per the theme (dark/light)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color inputBg = isDark ? AppColors.cardDark : Colors.white;
    final Color divider = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;
    final weatherNotifier = WeatherProvider.of(context);
    final weather = weatherNotifier.weather;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_pin, color: AppColors.primaryLight, size: 20),
          const SizedBox(width: 5),
          const Text(
            "Madikeri, Coorg",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
          ),
          const Spacer(),
          if (weatherNotifier.isLoading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (weather != null) ...[
            Icon(weather.icon, color: AppColors.primaryLight, size: 20),
            const SizedBox(width: 5),
            Text(
              "${weather.tempC.round()}°C - ${weather.condition}",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ] else
            Text(
              "Weather unavailable",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
        ],
      ),
    );
  }
}
