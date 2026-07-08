// lib/screens/trip_planner/trip_planner_screen.dart

import 'package:flutter/material.dart';
import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/models/trip_plan.dart';
import 'package:one_coorg/providers/favourites_provider.dart';
import 'package:one_coorg/providers/trip_plans_provider.dart';
import 'package:one_coorg/services/place_service.dart';
import 'package:one_coorg/services/trip_planner_service.dart';
import 'package:one_coorg/services/trip_weather_service.dart';
import 'package:one_coorg/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

const Map<String, Color> _categoryAccents = {
  "All": AppColors.primary,
  "Waterfalls": Color(0xFF1565C0),
  "Temples": Color(0xFFE65100),
  "Viewpoints": Color(0xFF6A1B9A),
  "Heritage": Color(0xFF6D4C41),
  "Reservoirs": AppColors.primaryLight,
};

// Reference point for weather — same as TripPlannerService's town-centre
// anchor. Kept as a small local duplicate rather than importing a private
// const; keep these two in sync if you ever move the reference point.
const double _refLat = 12.4244;
const double _refLng = 75.7382;

const List<String> _weekdayShort = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];
const List<String> _monthShort = [
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime d) =>
    '${_weekdayShort[d.weekday - 1]}, ${d.day} ${_monthShort[d.month]}';

class TripPlannerScreen extends StatefulWidget {
  // Pass an existing plan to open directly in view/edit mode instead of the
  // blank create flow.
  final TripPlan? existingPlan;

  const TripPlannerScreen({super.key, this.existingPlan});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _days = 3;
  DateTime _startDate = DateTime.now();

  // Keyed by place id so selection survives across list refetches.
  final Map<String, TouristPlace> _selected = {};

  // The selection stays synced to FavouritesProvider (so a favourite added
  // or removed on another screen shows up here immediately) right up until
  // the user makes their first manual edit on THIS screen — add, remove, or
  // confirm from the picker. After that, we stop overwriting their choices.
  bool _userHasEdited = false;

  bool _generating = false;
  TripPlan? _plan;

  Map<String, DayForecast>? _forecast;
  bool _loadingForecast = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingPlan != null) {
      _plan = widget.existingPlan;
      _days = widget.existingPlan!.days.length;
      _startDate = widget.existingPlan!.startDate ?? DateTime.now();
      _userHasEdited = true; // editing a saved plan — don't touch _selected
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadForecast());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = FavouritesProvider.of(context);
    if (!_userHasEdited && notifier.isLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _userHasEdited) return;
        setState(() {
          _selected
            ..clear()
            ..addEntries(notifier.favourites.map((p) => MapEntry(p.id, p)));
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
    setState(() {
      _userHasEdited = true;
      _selected.remove(id);
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _generate() async {
    if (_selected.isEmpty) return;
    setState(() => _generating = true);

    // Small artificial delay so the "generating" state is perceptible even
    // though the clustering itself runs in a few milliseconds.
    await Future.delayed(const Duration(milliseconds: 500));

    final generated = TripPlannerService.generate(
      places: _selected.values.toList(),
      requestedDays: _days,
      startDate: _startDate,
      title: _plan?.title ?? 'New Trip',
    );

    // Preserve identity across a regenerate-while-editing, so Save updates
    // the same saved trip instead of creating a duplicate.
    final finalPlan = _plan != null
        ? generated.copyWith(id: _plan!.id, createdAt: _plan!.createdAt)
        : generated;

    if (!mounted) return;
    setState(() {
      _plan = finalPlan;
      _generating = false;
    });
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    if (_plan == null || _plan!.days.isEmpty) return;
    setState(() => _loadingForecast = true);

    try {
      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      final daysAhead = _startDate.difference(todayDateOnly).inDays;
      final totalSpan = daysAhead + _plan!.days.length;

      if (daysAhead < 0 || totalSpan > 16) {
        // Outside Open-Meteo's free forecast window — skip quietly.
        if (!mounted) return;
        setState(() {
          _forecast = {};
          _loadingForecast = false;
        });
        return;
      }

      final forecast = await TripWeatherService.fetchForecast(
        lat: _refLat,
        lng: _refLng,
        days: totalSpan,
      );
      if (!mounted) return;
      setState(() {
        _forecast = forecast;
        _loadingForecast = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _forecast = {};
        _loadingForecast = false;
      });
    }
  }

  void _editSelection() {
    setState(() {
      if (_plan != null) {
        _selected.clear();
        for (final day in _plan!.days) {
          for (final p in day.places) {
            _selected[p.id] = p;
          }
        }
        _days = _plan!.days.length;
        _userHasEdited = true;
      }
      _plan = null;
    });
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
            _userHasEdited = true;
            _selected.clear();
            for (final p in chosen) {
              _selected[p.id] = p;
            }
          });
        },
      ),
    );
  }

  void _reorderWithinDay(int dayIndex, int oldIndex, int newIndex) {
    if (_plan == null) return;
    final days = List<TripDay>.from(_plan!.days);
    final places = List<TouristPlace>.from(days[dayIndex].places);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = places.removeAt(oldIndex);
    places.insert(newIndex, moved);
    days[dayIndex] = TripPlannerService.recomputeDayMetrics(
      days[dayIndex].copyWith(places: places),
    );
    setState(() => _plan = _plan!.copyWith(days: days));
  }

  void _movePlaceToDay(int fromDayIndex, String placeId, int toDayIndex) {
    if (_plan == null || fromDayIndex == toDayIndex) return;
    final days = List<TripDay>.from(_plan!.days);
    final fromPlaces = List<TouristPlace>.from(days[fromDayIndex].places);
    final place = fromPlaces.firstWhere((p) => p.id == placeId);
    fromPlaces.removeWhere((p) => p.id == placeId);
    final toPlaces = List<TouristPlace>.from(days[toDayIndex].places)
      ..add(place);

    days[fromDayIndex] = TripPlannerService.recomputeDayMetrics(
      days[fromDayIndex].copyWith(places: fromPlaces),
    );
    days[toDayIndex] = TripPlannerService.recomputeDayMetrics(
      days[toDayIndex].copyWith(places: toPlaces),
    );

    setState(() => _plan = _plan!.copyWith(days: days));
  }

  void _removePlaceFromPlan(int dayIndex, String placeId) {
    if (_plan == null) return;
    final days = List<TripDay>.from(_plan!.days);
    final places = List<TouristPlace>.from(days[dayIndex].places)
      ..removeWhere((p) => p.id == placeId);
    days[dayIndex] = TripPlannerService.recomputeDayMetrics(
      days[dayIndex].copyWith(places: places),
    );
    setState(() => _plan = _plan!.copyWith(days: days));
  }

  Future<void> _openDayInMaps(TripDay day) async {
    if (day.places.isEmpty) return;
    final destination = day.places.last;
    final waypoints = day.places
        .sublist(0, day.places.length - 1)
        .map((p) => '${p.lat},${p.lng}')
        .join('|');

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${destination.lat},${destination.lng}'
      '${waypoints.isNotEmpty ? '&waypoints=$waypoints' : ''}'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveTrip() async {
    if (_plan == null) return;
    final controller = TextEditingController(
      text: _plan!.title == 'New Trip' ? '' : _plan!.title,
    );

    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Name this trip'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Coorg Weekend Getaway',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    final toSave = _plan!.copyWith(title: title);
    await TripPlansProvider.of(context).saveOrUpdate(toSave);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trip saved')));

    // If this screen was opened to view/edit an existing saved trip (pushed
    // as its own route via _openSavedTrip), go back to whatever screen
    // opened it.
    if (widget.existingPlan != null && Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    // Otherwise this was a brand-new trip created from scratch on the main
    // planner screen — reset back to the planning view, where it'll now
    // show up under "Saved Trips".
    setState(() {
      _plan = null;
      _selected.clear();
      _userHasEdited = false;
      _days = 3;
      _startDate = DateTime.now();
    });
  }

  // Opens a saved trip in a fresh TripPlannerScreen instance, in edit mode.
  void _openSavedTrip(TripPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TripPlannerScreen(existingPlan: plan)),
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
    final tripPlans = TripPlansProvider.of(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _plan != null
            ? _ItineraryView(
                plan: _plan!,
                forecast: _forecast,
                loadingForecast: _loadingForecast,
                onEdit: _editSelection,
                onSave: _saveTrip,
                onReorderWithinDay: _reorderWithinDay,
                onMoveToDay: _movePlaceToDay,
                onRemoveFromPlan: _removePlaceFromPlan,
                onOpenInMaps: _openDayInMaps,
                textPri: textPri,
                textSec: textSec,
                isDark: isDark,
              )
            : _PlanningView(
                days: _days,
                startDate: _startDate,
                selected: _selected.values.toList(),
                loadingSaved: !favouritesLoaded,
                generating: _generating,
                onIncrement: _incrementDays,
                onDecrement: _decrementDays,
                onPickStartDate: _pickStartDate,
                onRemove: _removePlace,
                onAddMore: _openPlacePicker,
                onGenerate: _generate,
                textPri: textPri,
                textSec: textSec,
                isDark: isDark,
                savedTrips: tripPlans.plans,
                savedTripsLoaded: tripPlans.isLoaded,
                onOpenSavedTrip: _openSavedTrip,
              ),
      ),
    );
  }
}

// ── Planning step ─────────────────────────────────────────────
class _PlanningView extends StatelessWidget {
  final int days;
  final DateTime startDate;
  final List<TouristPlace> selected;
  final bool loadingSaved;
  final bool generating;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onPickStartDate;
  final void Function(String id) onRemove;
  final VoidCallback onAddMore;
  final VoidCallback onGenerate;
  final Color textPri;
  final Color textSec;
  final bool isDark;
  final List<TripPlan> savedTrips;
  final bool savedTripsLoaded;
  final void Function(TripPlan plan) onOpenSavedTrip;

  const _PlanningView({
    required this.days,
    required this.startDate,
    required this.selected,
    required this.loadingSaved,
    required this.generating,
    required this.onIncrement,
    required this.onDecrement,
    required this.onPickStartDate,
    required this.onRemove,
    required this.onAddMore,
    required this.onGenerate,
    required this.textPri,
    required this.textSec,
    required this.isDark,
    required this.savedTrips,
    required this.savedTripsLoaded,
    required this.onOpenSavedTrip,
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
        const SizedBox(height: 24),

        // ── Saved trips ──────────────────────────────────────
        if (savedTripsLoaded && savedTrips.isNotEmpty) ...[
          Text(
            "SAVED TRIPS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textSec,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: savedTrips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final plan = savedTrips[i];
                return _SavedTripCard(
                  plan: plan,
                  cardBg: cardBg,
                  divider: divider,
                  textPri: textPri,
                  textSec: textSec,
                  isDark: isDark,
                  onTap: () => onOpenSavedTrip(plan),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
        ],

        // ── Start date ──────────────────────────────────────
        Text(
          "STARTING FROM",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textSec,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onPickStartDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: divider),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: isDark ? AppColors.primaryBright : AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(startDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const Spacer(),
                Text(
                  "Change",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryBright : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

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

class _SavedTripCard extends StatelessWidget {
  final TripPlan plan;
  final Color cardBg;
  final Color divider;
  final Color textPri;
  final Color textSec;
  final bool isDark;
  final VoidCallback onTap;

  const _SavedTripCard({
    required this.plan,
    required this.cardBg,
    required this.divider,
    required this.textPri,
    required this.textSec,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.map_rounded,
              size: 20,
              color: isDark ? AppColors.primaryBright : AppColors.primary,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPri,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${plan.days.length} day${plan.days.length == 1 ? '' : 's'} · ${plan.totalPlaces} places",
                  style: TextStyle(fontSize: 11, color: textSec),
                ),
              ],
            ),
          ],
        ),
      ),
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
  final Map<String, DayForecast>? forecast;
  final bool loadingForecast;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final void Function(int dayIndex, int oldIndex, int newIndex)
  onReorderWithinDay;
  final void Function(int fromDayIndex, String placeId, int toDayIndex)
  onMoveToDay;
  final void Function(int dayIndex, String placeId) onRemoveFromPlan;
  final void Function(TripDay day) onOpenInMaps;
  final Color textPri;
  final Color textSec;
  final bool isDark;

  const _ItineraryView({
    required this.plan,
    required this.forecast,
    required this.loadingForecast,
    required this.onEdit,
    required this.onSave,
    required this.onReorderWithinDay,
    required this.onMoveToDay,
    required this.onRemoveFromPlan,
    required this.onOpenInMaps,
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
                plan.title == 'New Trip' ? "Your Itinerary" : plan.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textPri,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
        const SizedBox(height: 6),
        Text(
          "Long-press a place to drag it onto another day",
          style: TextStyle(
            fontSize: 11,
            color: textSec,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.bookmark_rounded, size: 18),
            label: const Text("Save Trip"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 20),

        ..._buildDayCards(cardBg, divider),
      ],
    );
  }

  // Built as a plain method (rather than an inline collection-for) so the
  // per-day forecast lookup can use a straightforward if-statement instead
  // of a ternary immediately followed by a null-aware index operator
  // (`cond ? map?[key] : null`) — that combination is a known Dart parsing
  // ambiguity and was surfacing as a "condition must be bool" error even
  // though the condition itself was a plain, valid bool expression.
  List<Widget> _buildDayCards(Color cardBg, Color divider) {
    final cards = <Widget>[];

    for (int dayIndex = 0; dayIndex < plan.days.length; dayIndex++) {
      final day = plan.days[dayIndex];

      DayForecast? dayForecast;
      if (day.date != null) {
        dayForecast = forecast?[forecastKeyFor(day.date!)];
      }

      cards.add(
        _DayCard(
          day: day,
          dayIndex: dayIndex,
          totalDays: plan.days.length,
          dayForecast: dayForecast,
          loadingForecast: loadingForecast,
          onReorder: (oldIndex, newIndex) =>
              onReorderWithinDay(dayIndex, oldIndex, newIndex),
          onMoveHere: (fromDayIndex, placeId) =>
              onMoveToDay(fromDayIndex, placeId, dayIndex),
          onMoveTo: (toDayIndex, placeId) =>
              onMoveToDay(dayIndex, placeId, toDayIndex),
          onRemove: (placeId) => onRemoveFromPlan(dayIndex, placeId),
          onOpenInMaps: () => onOpenInMaps(day),
          cardBg: cardBg,
          divider: divider,
          textPri: textPri,
          textSec: textSec,
          isDark: isDark,
        ),
      );
    }

    return cards;
  }
}

class _DayCard extends StatelessWidget {
  final TripDay day;
  final int dayIndex;
  final int totalDays;
  final DayForecast? dayForecast;
  final bool loadingForecast;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int fromDayIndex, String placeId) onMoveHere;
  final void Function(int toDayIndex, String placeId) onMoveTo;
  final void Function(String placeId) onRemove;
  final VoidCallback onOpenInMaps;
  final Color cardBg;
  final Color divider;
  final Color textPri;
  final Color textSec;
  final bool isDark;

  const _DayCard({
    required this.day,
    required this.dayIndex,
    required this.totalDays,
    required this.dayForecast,
    required this.loadingForecast,
    required this.onReorder,
    required this.onMoveHere,
    required this.onMoveTo,
    required this.onRemove,
    required this.onOpenInMaps,
    required this.cardBg,
    required this.divider,
    required this.textPri,
    required this.textSec,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) =>
          details.data['dayIndex'] != dayIndex,
      onAcceptWithDetails: (details) {
        onMoveHere(
          details.data['dayIndex'] as int,
          details.data['placeId'] as String,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDropTarget ? AppColors.primary : divider,
              width: isDropTarget ? 2 : 1,
            ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Day ${day.dayNumber}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                          ),
                        ),
                        if (day.date != null)
                          Text(
                            _formatDate(day.date!),
                            style: TextStyle(fontSize: 11, color: textSec),
                          ),
                      ],
                    ),
                  ),
                  if (!day.isEmpty)
                    GestureDetector(
                      onTap: onOpenInMaps,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map_rounded,
                              size: 14,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Maps",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.primaryBright
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // ── Metrics row: distance/time + weather ──
              if (!day.isEmpty || dayForecast != null || loadingForecast)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (day.distanceKm > 0)
                        _MetricChip(
                          icon: Icons.route_rounded,
                          label:
                              "${day.distanceKm.toStringAsFixed(1)} km · ~${day.driveMinutes} min",
                          textSec: textSec,
                          isDark: isDark,
                        ),
                      if (loadingForecast)
                        _MetricChip(
                          icon: Icons.cloud_outlined,
                          label: "Loading weather…",
                          textSec: textSec,
                          isDark: isDark,
                        )
                      else if (dayForecast != null)
                        _MetricChip(
                          icon: dayForecast!.icon,
                          label:
                              "${dayForecast!.description} · ${dayForecast!.tempMinC.round()}–${dayForecast!.tempMaxC.round()}°C",
                          textSec: textSec,
                          isDark: isDark,
                          highlight: dayForecast!.isRainy,
                        ),
                    ],
                  ),
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
                        "Free day — drag a place here",
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
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorder: onReorder,
                  itemCount: day.places.length,
                  itemBuilder: (context, i) {
                    final place = day.places[i];
                    return _StopRow(
                      key: ValueKey(place.id),
                      index: i + 1,
                      dayIndex: dayIndex,
                      totalDays: totalDays,
                      place: place,
                      isLast: i == day.places.length - 1,
                      textPri: textPri,
                      textSec: textSec,
                      divider: divider,
                      onMoveTo: (toDayIndex) => onMoveTo(toDayIndex, place.id),
                      onRemove: () => onRemove(place.id),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textSec;
  final bool isDark;
  final bool highlight;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.textSec,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? const Color(0xFF1565C0)
        : (isDark ? AppColors.primaryBright : AppColors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  final int index;
  final int dayIndex;
  final int totalDays;
  final TouristPlace place;
  final bool isLast;
  final Color textPri;
  final Color textSec;
  final Color divider;
  final void Function(int toDayIndex) onMoveTo;
  final VoidCallback onRemove;

  const _StopRow({
    super.key,
    required this.index,
    required this.dayIndex,
    required this.totalDays,
    required this.place,
    required this.isLast,
    required this.textPri,
    required this.textSec,
    required this.divider,
    required this.onMoveTo,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _categoryAccents[place.category] ?? AppColors.primary;

    return LongPressDraggable<Map<String, dynamic>>(
      data: {'dayIndex': dayIndex, 'placeId': place.id},
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            place.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _stopRowContent(context, accent),
      ),
      child: ReorderableDragStartListener(
        index: index - 1,
        child: _stopRowContent(context, accent),
      ),
    );
  }

  Widget _stopRowContent(BuildContext context, Color accent) {
    return IntrinsicHeight(
      key: ValueKey('content_${place.id}'),
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
                  PopupMenuButton<int>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: textSec,
                    ),
                    itemBuilder: (context) => [
                      if (totalDays > 1)
                        for (int d = 0; d < totalDays; d++)
                          if (d != dayIndex)
                            PopupMenuItem(
                              value: d,
                              child: Text("Move to Day ${d + 1}"),
                            ),
                      const PopupMenuItem(
                        value: -1,
                        child: Text(
                          "Remove from trip",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == -1) {
                        onRemove();
                      } else {
                        onMoveTo(value);
                      }
                    },
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
