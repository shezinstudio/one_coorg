// lib/screens/trip_planner/trip_planner_screen.dart

import 'package:flutter/material.dart';
import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/models/trip_plan.dart';
import 'package:one_coorg/providers/favourites_provider.dart';
import 'package:one_coorg/services/place_service.dart';
import 'package:one_coorg/services/trip_planner_service.dart';
import 'package:one_coorg/theme/app_colors.dart';

const Map<String, Color> _categoryAccents = {
  "All": AppColors.primary,
  "Waterfalls": Color(0xFF1565C0),
  "Temples": Color(0xFFE65100),
  "Viewpoints": Color(0xFF6A1B9A),
  "Heritage": Color(0xFF6D4C41),
  "Reservoirs": AppColors.primaryLight,
};

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _days = 3;

  // Keyed by place id so selection survives across list refetches.
  final Map<String, TouristPlace> _selected = {};

  // Ensures we only copy favourites into _selected once — after that, the
  // user's manual add/remove choices in this screen take over, and we don't
  // want a later favourite toggled elsewhere to silently reset selection.
  bool _seededFromFavourites = false;

  bool _generating = false;
  TripPlan? _plan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = FavouritesProvider.of(context);
    if (!_seededFromFavourites && notifier.isLoaded) {
      // Defer the setState to after this frame — didChangeDependencies can
      // fire during the build phase (e.g. right after the provider finishes
      // its async load and calls notifyListeners()).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          for (final p in notifier.favourites) {
            _selected[p.id] = p;
          }
          _seededFromFavourites = true;
        });
      });
    }
  }

  void _incrementDays() {
    if (_days < 14) setState(() => _days++);
  }

  void _decrementDays() {
    if (_days > 1) setState(() => _days--);
  }

  void _removePlace(String id) {
    setState(() => _selected.remove(id));
  }

  Future<void> _generate() async {
    if (_selected.isEmpty) return;
    setState(() => _generating = true);

    // Small artificial delay so the "generating" state is perceptible even
    // though the clustering itself runs in a few milliseconds.
    await Future.delayed(const Duration(milliseconds: 500));

    final plan = TripPlannerService.generate(
      places: _selected.values.toList(),
      requestedDays: _days,
    );

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _generating = false;
    });
  }

  void _editSelection() {
    setState(() => _plan = null);
  }

  Future<void> _openPlacePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlacePickerSheet(
        initiallySelected: _selected.keys.toSet(),
        onConfirm: (chosen) {
          setState(() {
            _selected.clear();
            for (final p in chosen) {
              _selected[p.id] = p;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPri = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSec = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final favouritesLoaded = FavouritesProvider.of(context).isLoaded;

    return Container(
      color: bg,
      child: SafeArea(
        child: _plan != null
            ? _ItineraryView(
                plan: _plan!,
                onEdit: _editSelection,
                textPri: textPri,
                textSec: textSec,
                isDark: isDark,
              )
            : _PlanningView(
                days: _days,
                selected: _selected.values.toList(),
                loadingSaved: !favouritesLoaded,
                generating: _generating,
                onIncrement: _incrementDays,
                onDecrement: _decrementDays,
                onRemove: _removePlace,
                onAddMore: _openPlacePicker,
                onGenerate: _generate,
                textPri: textPri,
                textSec: textSec,
                isDark: isDark,
              ),
      ),
    );
  }
}

// ── Planning step ─────────────────────────────────────────────
class _PlanningView extends StatelessWidget {
  final int days;
  final List<TouristPlace> selected;
  final bool loadingSaved;
  final bool generating;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final void Function(String id) onRemove;
  final VoidCallback onAddMore;
  final VoidCallback onGenerate;
  final Color textPri;
  final Color textSec;
  final bool isDark;

  const _PlanningView({
    required this.days,
    required this.selected,
    required this.loadingSaved,
    required this.generating,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onAddMore,
    required this.onGenerate,
    required this.textPri,
    required this.textSec,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Text(
          "Plan Your Trip",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: textPri,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Pick your days and places — we'll build the route",
          style: TextStyle(fontSize: 13, color: textSec),
        ),
        const SizedBox(height: 28),

        // ── Day count stepper ──────────────────────────────
        Text(
          "TRIP LENGTH",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textSec,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: divider),
          ),
          child: Row(
            children: [
              _StepperButton(icon: Icons.remove_rounded, onTap: onDecrement),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "$days",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.primaryBright
                              : AppColors.primary,
                          height: 1,
                        ),
                      ),
                      Text(
                        days == 1 ? "day" : "days",
                        style: TextStyle(fontSize: 12, color: textSec),
                      ),
                    ],
                  ),
                ),
              ),
              _StepperButton(icon: Icons.add_rounded, onTap: onIncrement),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Selected places ─────────────────────────────────
        Row(
          children: [
            Text(
              "PLACES TO VISIT",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textSec,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            Text(
              "${selected.length} selected",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryBright : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (loadingSaved)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: isDark ? AppColors.primaryBright : AppColors.primary,
              ),
            ),
          )
        else if (selected.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: divider),
            ),
            child: Column(
              children: [
                Icon(Icons.map_outlined, size: 32, color: textSec),
                const SizedBox(height: 10),
                Text(
                  "No places added yet",
                  style: TextStyle(
                    color: textSec,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ...selected.map(
            (p) => _SelectedPlaceTile(
              place: p,
              onRemove: () => onRemove(p.id),
              cardBg: cardBg,
              divider: divider,
              textPri: textPri,
              textSec: textSec,
            ),
          ),

        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAddMore,
          icon: Icon(
            Icons.add_rounded,
            color: isDark ? AppColors.primaryBright : AppColors.primary,
          ),
          label: Text(
            "Add places",
            style: TextStyle(
              color: isDark ? AppColors.primaryBright : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(
              color: (isDark ? AppColors.primaryBright : AppColors.primary)
                  .withValues(alpha: 0.4),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selected.isEmpty || generating ? null : onGenerate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: generating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Generate Itinerary",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}

class _SelectedPlaceTile extends StatelessWidget {
  final TouristPlace place;
  final VoidCallback onRemove;
  final Color cardBg;
  final Color divider;
  final Color textPri;
  final Color textSec;

  const _SelectedPlaceTile({
    required this.place,
    required this.onRemove,
    required this.cardBg,
    required this.divider,
    required this.textPri,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _categoryAccents[place.category] ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              place.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 48,
                height: 48,
                color: accent.withValues(alpha: 0.15),
                child: Center(
                  child: Text(
                    place.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPri,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  place.category,
                  style: TextStyle(fontSize: 12, color: textSec),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 18, color: textSec),
          ),
        ],
      ),
    );
  }
}

// ── Place picker sheet ────────────────────────────────────────
class _PlacePickerSheet extends StatefulWidget {
  final Set<String> initiallySelected;
  final void Function(List<TouristPlace> chosen) onConfirm;

  const _PlacePickerSheet({
    required this.initiallySelected,
    required this.onConfirm,
  });

  @override
  State<_PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends State<_PlacePickerSheet> {
  late Future<List<TouristPlace>> _future;
  final Map<String, TouristPlace> _chosen = {};
  String _query = "";

  @override
  void initState() {
    super.initState();
    _future = PlaceService.fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.cardDark : Colors.white;
    final textPri = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSec = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        "Add Places",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPri,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${_chosen.length + widget.initiallySelected.length} selected",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.primaryBright
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: "Search places...",
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<TouristPlace>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Couldn't load places",
                            style: TextStyle(color: textSec),
                          ),
                        );
                      }
                      final all = snapshot.data ?? [];
                      final filtered = _query.isEmpty
                          ? all
                          : all
                                .where(
                                  (p) => p.name.toLowerCase().contains(
                                    _query.toLowerCase(),
                                  ),
                                )
                                .toList();

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final place = filtered[i];
                          final isAlreadySelected = widget.initiallySelected
                              .contains(place.id);
                          final isChosen =
                              isAlreadySelected ||
                              _chosen.containsKey(place.id);
                          final accent =
                              _categoryAccents[place.category] ??
                              AppColors.primary;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isAlreadySelected) {
                                  // Demote a pre-selected place to "removed"
                                  // by tracking it as explicitly unchosen.
                                  widget.initiallySelected.remove(place.id);
                                } else if (_chosen.containsKey(place.id)) {
                                  _chosen.remove(place.id);
                                } else {
                                  _chosen[place.id] = place;
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isChosen
                                    ? accent.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isChosen ? accent : divider,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      place.imageUrl,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 44,
                                        height: 44,
                                        color: accent.withValues(alpha: 0.15),
                                        child: Center(
                                          child: Text(
                                            place.emoji,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: textPri,
                                          ),
                                        ),
                                        Text(
                                          place.category,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textSec,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isChosen
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: isChosen ? accent : divider,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final all = await _future;
                        final keptOriginal = all
                            .where(
                              (p) => widget.initiallySelected.contains(p.id),
                            )
                            .toList();
                        widget.onConfirm([...keptOriginal, ..._chosen.values]);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Generated itinerary view ──────────────────────────────────
class _ItineraryView extends StatelessWidget {
  final TripPlan plan;
  final VoidCallback onEdit;
  final Color textPri;
  final Color textSec;
  final bool isDark;

  const _ItineraryView({
    required this.plan,
    required this.onEdit,
    required this.textPri,
    required this.textSec,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Your Itinerary",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textPri,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_rounded,
                size: 16,
                color: isDark ? AppColors.primaryBright : AppColors.primary,
              ),
              label: Text(
                "Edit",
                style: TextStyle(
                  color: isDark ? AppColors.primaryBright : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Text(
          "${plan.totalPlaces} places across ${plan.days.length} day${plan.days.length == 1 ? '' : 's'}",
          style: TextStyle(fontSize: 13, color: textSec),
        ),
        const SizedBox(height: 20),

        for (final day in plan.days)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "${day.dayNumber}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Day ${day.dayNumber}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPri,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (day.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.self_improvement_rounded,
                          size: 18,
                          color: textSec,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Free day — no places planned",
                          style: TextStyle(
                            fontSize: 13,
                            color: textSec,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (int i = 0; i < day.places.length; i++)
                    _StopRow(
                      index: i + 1,
                      place: day.places[i],
                      isLast: i == day.places.length - 1,
                      textPri: textPri,
                      textSec: textSec,
                      divider: divider,
                    ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  final int index;
  final TouristPlace place;
  final bool isLast;
  final Color textPri;
  final Color textSec;
  final Color divider;

  const _StopRow({
    required this.index,
    required this.place,
    required this.isLast,
    required this.textPri,
    required this.textSec,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _categoryAccents[place.category] ?? AppColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 1.6),
                ),
                child: Center(
                  child: Text(
                    "$index",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 1.4, color: divider)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      place.imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 44,
                        height: 44,
                        color: accent.withValues(alpha: 0.15),
                        child: Center(
                          child: Text(
                            place.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                          ),
                        ),
                        Text(
                          "${place.category} · ${place.duration}",
                          style: TextStyle(fontSize: 11, color: textSec),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
