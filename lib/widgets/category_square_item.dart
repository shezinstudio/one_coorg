import 'package:flutter/material.dart';
import 'package:one_coorg/theme/app_colors.dart';

/// Square category chip: an image tile on top, category name below it,
/// the whole thing sitting on a green card. Replaces the icon-based
/// CategoryItem in the "Popular Categories" row.
class CategorySquareItem extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;
  final double size;

  const CategorySquareItem({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onTap,
    this.size = 78,
  });

  // Fixed padding, the gap above the label, and the label's own line
  // height — everything that isn't the image, inside the square card.
  static const double _padding = 6;
  static const double _gapAboveLabel = 4;
  static const double _labelLineHeight = 13;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final double innerSide = size - (_padding * 2);
    final double imageHeight = innerSide - _gapAboveLabel - _labelLineHeight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size, // card is a perfect square — width == height
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          color: isDark ? AppColors.forestGreenDark : AppColors.forestGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: imageUrl.isEmpty
                    ? Container(color: Colors.white.withValues(alpha: 0.15))
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.white.withValues(alpha: 0.1),
                            child: const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            SizedBox(height: _gapAboveLabel),
            SizedBox(
              height: _labelLineHeight,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
