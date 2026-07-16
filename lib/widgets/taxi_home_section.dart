import 'package:flutter/material.dart';

/// Brand tokens — reuse your shared AppColors if you already centralize
/// these instead of redefining locally.
class _Brand {
  static const forestGreen = Color(0xFF0B2B26);
  static const forestGreenDark = Color(0xFF1B4332);
  static const amber = Color(0xFFD9A441);
}

/// Compact "Need a ride?" promo card for the home screen, placed below
/// the Place of the Day section. Tapping it should either:
///  a) push to ServicesScreen with the Taxi Booking chip pre-selected, or
///  b) open the inline taxi booking sheet directly.
/// Wire whichever fits your navigation via [onTap].
class TaxiHomeSection extends StatelessWidget {
  final VoidCallback onTap;

  const TaxiHomeSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_Brand.forestGreen, _Brand.forestGreenDark],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _Brand.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: Color(0xFF412402),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Need a ride?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Book a taxi anywhere in Kodagu',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _Brand.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Color(0xFF412402),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
