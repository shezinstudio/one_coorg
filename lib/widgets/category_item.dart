import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String emoji; // or use Icon/SvgPicture/Image instead
  final String label;

  const CategoryItem({super.key, required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ), // light beige/gray
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
