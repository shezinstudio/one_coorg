import 'package:one_coorg/screens/intro/intro_page_template.dart';
import 'package:flutter/material.dart';

class IntroPageThree extends StatelessWidget {
  const IntroPageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroPageTemplate(
      imagePath: "assets/images/screen_three.png",
      eyebrow: "Explore",
      title: "Follow the Path of Rivers and Roads",
      description:
          "Discover winding rivers and ancient trails that lead to adventure. Coorg Explorer is your guide to mapping out the ultimate wilderness experience.",
    );
  }
}
