import 'package:one_coorg/screens/intro/intro_page_template.dart';
import 'package:flutter/material.dart';

class IntroPageFour extends StatelessWidget {
  const IntroPageFour({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroPageTemplate(
      imagePath: "assets/images/screen_four.png",
      eyebrow: "Immerse",
      title: "Seek Culture & Nature with Explorer",
      description:
          "Navigate from iconic landmarks to local heritage sites. Immerse yourself in the vibrant culture and nature that defines Coorg's unique charm.",
    );
  }
}
