import 'package:one_coorg/screens/intro/intro_page_template.dart';
import 'package:flutter/material.dart';

class IntroScreenTwo extends StatelessWidget {
  const IntroScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroPageTemplate(
      imagePath: "assets/images/screen_two.png",
      eyebrow: "Discover",
      title: "Experience Misty Hills & Waterfalls",
      description:
          "Explore lush green coffee plantations. Witness the beauty of hidden, cascading waterfalls. Feel the pure mist of the unique Coorg Explorer trails.",
    );
  }
}
