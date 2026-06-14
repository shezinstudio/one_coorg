import 'package:one_coorg/screens/intro/intro_page_template.dart';
import 'package:flutter/material.dart';

class IntroScreenOne extends StatelessWidget {
  const IntroScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroPageTemplate(
      imagePath: "assets/images/screen_one.png",
      title: "The Journey Begins in Coorg",
      description:
          "Embark on your adventure with Coorg Explorer. Discover the heart of this stunning hill station and unlock the secrets of its misty landscapes.",
    );
  }
}
