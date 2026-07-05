import 'package:flutter/material.dart';

class TripPlannerScreen extends StatelessWidget {
  const TripPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Planner")),
      body: const Center(child: Text("Trip Planner Screen")),
    );
  }
}
