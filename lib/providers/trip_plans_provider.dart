// lib/providers/trip_plans_provider.dart

import 'dart:convert';
import 'package:one_coorg/models/trip_plan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripPlansNotifier extends ChangeNotifier {
  static const _idsKey = 'trip_plan_ids';

  final List<TripPlan> _plans = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  // Newest first.
  List<TripPlan> get plans => List.unmodifiable(
    _plans..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  TripPlansNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_idsKey) ?? [];

    for (final id in ids) {
      final raw = prefs.getString('trip_$id');
      if (raw != null) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          _plans.add(TripPlan.fromMap(map));
        } catch (_) {
          /* skip corrupted entry */
        }
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persistIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_idsKey, _plans.map((p) => p.id).toList());
  }

  TripPlan? getById(String id) {
    for (final p in _plans) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Saves a new plan or overwrites an existing one with the same id.
  Future<void> saveOrUpdate(TripPlan plan) async {
    final index = _plans.indexWhere((p) => p.id == plan.id);
    if (index >= 0) {
      _plans[index] = plan;
    } else {
      _plans.add(plan);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trip_${plan.id}', jsonEncode(plan.toMap()));
    await _persistIds();
  }

  Future<void> delete(String id) async {
    _plans.removeWhere((p) => p.id == id);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('trip_$id');
    await _persistIds();
  }
}

class TripPlansProvider extends InheritedNotifier<TripPlansNotifier> {
  const TripPlansProvider({
    super.key,
    required TripPlansNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static TripPlansNotifier of(BuildContext context) {
    final p = context.dependOnInheritedWidgetOfExactType<TripPlansProvider>();
    assert(p != null, 'No TripPlansProvider found in widget tree');
    return p!.notifier!;
  }
}
