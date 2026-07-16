import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:one_coorg/models/tourist_place.dart';
import 'package:one_coorg/services/place_service.dart';

/// Brand tokens — swap for your shared AppColors if you already
/// centralize these instead of redefining locally.
class _Brand {
  static const forestGreen = Color(0xFF0B2B26);
  static const forestGreenDark = Color(0xFF1B4332);
  static const amber = Color(0xFFD9A441);
  static const cream = Color(0xFFFAF7F2);
  static const textMuted = Color(0xFF6B7280);
}

// ─────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────

enum TourPackage { oneDay, twoDay, threeDay, custom }

extension TourPackageX on TourPackage {
  String get label => switch (this) {
    TourPackage.oneDay => '1 Day',
    TourPackage.twoDay => '2 Days',
    TourPackage.threeDay => '3 Days',
    TourPackage.custom => 'Custom',
  };

  String get subtitle => switch (this) {
    TourPackage.oneDay => 'Quick highlights tour',
    TourPackage.twoDay => 'Cover more, relaxed pace',
    TourPackage.threeDay => 'The full Kodagu experience',
    TourPackage.custom => 'Pick your own dates & stops',
  };

  IconData get icon => switch (this) {
    TourPackage.oneDay => Icons.wb_sunny_rounded,
    TourPackage.twoDay => Icons.calendar_view_day_rounded,
    TourPackage.threeDay => Icons.event_note_rounded,
    TourPackage.custom => Icons.tune_rounded,
  };

  /// Duration in days for the fixed packs. Custom is user-defined.
  int? get days => switch (this) {
    TourPackage.oneDay => 1,
    TourPackage.twoDay => 2,
    TourPackage.threeDay => 3,
    TourPackage.custom => null,
  };

  /// Starting indicative fare per day — adjust to your real pricing or
  /// pull from a Supabase `tour_rates` table instead of hardcoding.
  int get ratePerDay => switch (this) {
    TourPackage.oneDay => 2500,
    TourPackage.twoDay => 2300,
    TourPackage.threeDay => 2100,
    TourPackage.custom => 2300,
  };

  /// Value stored in the `package_type` column in Supabase.
  String get dbValue => switch (this) {
    TourPackage.oneDay => 'one_day',
    TourPackage.twoDay => 'two_day',
    TourPackage.threeDay => 'three_day',
    TourPackage.custom => 'custom',
  };
}

enum BookingStatus { pending, confirmed, completed, cancelled }

extension BookingStatusX on BookingStatus {
  static BookingStatus fromDb(String value) => switch (value) {
    'confirmed' => BookingStatus.confirmed,
    'completed' => BookingStatus.completed,
    'cancelled' => BookingStatus.cancelled,
    _ => BookingStatus.pending,
  };

  String get label => switch (this) {
    BookingStatus.pending => 'Pending',
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.completed => 'Completed',
    BookingStatus.cancelled => 'Cancelled',
  };

  Color get color => switch (this) {
    BookingStatus.pending => _Brand.amber,
    BookingStatus.confirmed => const Color(0xFF2E7D32),
    BookingStatus.completed => _Brand.textMuted,
    BookingStatus.cancelled => const Color(0xFFC62828),
  };
}

class TourBooking {
  final String id;
  final TourPackage package;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupLocation;
  final String dropLocation;
  final int passengers;
  final String? notes;
  final int estimatedFare;
  final BookingStatus status;
  final DateTime createdAt;
  final List<String> placeIds;

  TourBooking({
    required this.id,
    required this.package,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    required this.dropLocation,
    required this.passengers,
    required this.notes,
    required this.estimatedFare,
    required this.status,
    required this.createdAt,
    required this.placeIds,
  });

  factory TourBooking.fromMap(Map<String, dynamic> map) {
    TourPackage packageFromDb(String value) => switch (value) {
      'one_day' => TourPackage.oneDay,
      'two_day' => TourPackage.twoDay,
      'three_day' => TourPackage.threeDay,
      _ => TourPackage.custom,
    };

    return TourBooking(
      id: map['id'].toString(),
      package: packageFromDb(map['package_type'] ?? 'custom'),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      pickupLocation: map['pickup_location'] ?? '',
      dropLocation: map['drop_location'] ?? '',
      passengers: (map['passengers'] as num?)?.toInt() ?? 1,
      notes: map['notes'],
      estimatedFare: (map['estimated_fare'] as num?)?.toInt() ?? 0,
      status: BookingStatusX.fromDb(map['status'] ?? 'pending'),
      createdAt: DateTime.parse(map['created_at']),
      placeIds:
          (map['place_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// Handles all Supabase reads/writes for tour bookings.
///
/// Expected table (adjust names to match your schema):
///
/// create table tour_bookings (
///   id uuid primary key default gen_random_uuid(),
///   user_id uuid references auth.users not null,
///   package_type text not null,           -- one_day | two_day | three_day | custom
///   start_date date not null,
///   end_date date not null,
///   pickup_location text not null,
///   drop_location text not null,
///   passengers int not null default 1,
///   notes text,
///   estimated_fare int not null default 0,
///   status text not null default 'pending', -- pending | confirmed | completed | cancelled
///   place_ids uuid[] not null default '{}', -- FKs into your existing places table
///   created_at timestamptz not null default now()
/// );
/// -- RLS: users can insert/select their own rows via user_id = auth.uid()
class TourBookingService {
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> createBooking({
    required TourPackage package,
    required DateTime startDate,
    required DateTime endDate,
    required String pickupLocation,
    required String dropLocation,
    required int passengers,
    required String? notes,
    required int estimatedFare,
    required List<String> placeIds,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You need to be signed in to book a tour.');
    }

    await _client.from('tour_bookings').insert({
      'user_id': userId,
      'package_type': package.dbValue,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'pickup_location': pickupLocation,
      'drop_location': dropLocation,
      'passengers': passengers,
      'notes': notes,
      'estimated_fare': estimatedFare,
      'status': 'pending',
      'place_ids': placeIds,
    });
  }

  static Future<List<TourBooking>> fetchMyBookings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('tour_bookings')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => TourBooking.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────

class TourBookingScreen extends StatefulWidget {
  const TourBookingScreen({super.key});

  @override
  State<TourBookingScreen> createState() => _TourBookingScreenState();
}

class _TourBookingScreenState extends State<TourBookingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Future<List<TourBooking>>? _historyFuture;
  late final Future<List<TouristPlace>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _historyFuture = TourBookingService.fetchMyBookings();
    _placesFuture = PlaceService.fetchPlaces();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshHistory() {
    setState(() => _historyFuture = TourBookingService.fetchMyBookings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Brand.cream,
      appBar: AppBar(
        backgroundColor: _Brand.forestGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book a Coorg Tour',
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _Brand.amber,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'New Booking'),
            Tab(text: 'My Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NewBookingTab(
            placesFuture: _placesFuture,
            onBookingCreated: () {
              _refreshHistory();
              _tabController.animateTo(1);
            },
          ),
          _MyBookingsTab(
            future: _historyFuture,
            placesFuture: _placesFuture,
            onRefresh: _refreshHistory,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// New Booking tab
// ─────────────────────────────────────────────────────────────────────────

class _NewBookingTab extends StatefulWidget {
  final VoidCallback onBookingCreated;
  final Future<List<TouristPlace>> placesFuture;
  const _NewBookingTab({
    required this.onBookingCreated,
    required this.placesFuture,
  });

  @override
  State<_NewBookingTab> createState() => _NewBookingTabState();
}

class _NewBookingTabState extends State<_NewBookingTab> {
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _notesController = TextEditingController();

  TourPackage _package = TourPackage.oneDay;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _customEndDate;
  int _passengers = 2;
  bool _sameAsPickupDrop = true;
  bool _submitting = false;
  final Map<String, TouristPlace> _selectedPlaces = {};

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime get _endDate {
    if (_package == TourPackage.custom) {
      return _customEndDate ?? _startDate;
    }
    final days = _package.days ?? 1;
    return _startDate.add(Duration(days: days - 1));
  }

  int get _tripDays => _endDate.difference(_startDate).inDays + 1;

  int get _estimatedFare => _package.ratePerDay * _tripDays;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      if (_customEndDate != null && _customEndDate!.isBefore(_startDate)) {
        _customEndDate = null;
      }
    });
  }

  Future<void> _pickCustomEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customEndDate ?? _startDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 30)),
    );
    if (picked == null) return;
    setState(() => _customEndDate = picked);
  }

  Future<void> _submit() async {
    if (_pickupController.text.trim().isEmpty) {
      _showSnack('Enter a pickup location.');
      return;
    }
    if (!_sameAsPickupDrop && _dropController.text.trim().isEmpty) {
      _showSnack('Enter a drop location, or toggle "Round trip".');
      return;
    }
    if (_package == TourPackage.custom && _customEndDate == null) {
      _showSnack('Pick an end date for your custom tour.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await TourBookingService.createBooking(
        package: _package,
        startDate: _startDate,
        endDate: _endDate,
        pickupLocation: _pickupController.text.trim(),
        dropLocation: _sameAsPickupDrop
            ? _pickupController.text.trim()
            : _dropController.text.trim(),
        passengers: _passengers,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        estimatedFare: _estimatedFare,
        placeIds: _selectedPlaces.keys.toList(),
      );
      if (!mounted) return;
      _showSnack('Booking request sent! Track it under "My Bookings".');
      widget.onBookingCreated();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not create booking: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, d MMM');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Choose a package'),
          const SizedBox(height: 10),
          _buildPackageGrid(),

          const SizedBox(height: 20),
          _sectionLabel(
            _package == TourPackage.custom ? 'Trip dates' : 'Start date',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _dateTile(
                  label: 'Start',
                  value: dateFormat.format(_startDate),
                  onTap: _pickStartDate,
                ),
              ),
              if (_package == TourPackage.custom) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _dateTile(
                    label: 'End',
                    value: _customEndDate == null
                        ? 'Select'
                        : dateFormat.format(_customEndDate!),
                    onTap: _pickCustomEndDate,
                  ),
                ),
              ],
            ],
          ),
          if (_package != TourPackage.custom) ...[
            const SizedBox(height: 6),
            Text(
              'Ends ${dateFormat.format(_endDate)} · $_tripDays day${_tripDays > 1 ? 's' : ''}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: _Brand.textMuted,
              ),
            ),
          ],

          const SizedBox(height: 20),
          _sectionLabel('Pickup & drop'),
          const SizedBox(height: 10),
          _textField(
            controller: _pickupController,
            hint: 'Pickup location',
            icon: Icons.my_location_rounded,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: _sameAsPickupDrop,
                activeColor: _Brand.forestGreen,
                onChanged: (v) => setState(() => _sameAsPickupDrop = v ?? true),
              ),
              const Text(
                'Round trip (drop = pickup)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: _Brand.forestGreen,
                ),
              ),
            ],
          ),
          if (!_sameAsPickupDrop) ...[
            const SizedBox(height: 4),
            _textField(
              controller: _dropController,
              hint: 'Drop location',
              icon: Icons.place_outlined,
            ),
          ],

          const SizedBox(height: 20),
          _sectionLabel('Places you\u2019d like to visit'),
          const SizedBox(height: 10),
          _buildPlacesPicker(),

          const SizedBox(height: 20),
          _sectionLabel('Passengers'),
          const SizedBox(height: 10),
          _passengerStepper(),

          const SizedBox(height: 20),
          _sectionLabel('Notes (optional)'),
          const SizedBox(height: 10),
          _textField(
            controller: _notesController,
            hint: 'Places you want to cover, timing preferences, etc.',
            icon: Icons.edit_note_rounded,
            maxLines: 3,
          ),

          const SizedBox(height: 22),
          _fareSummary(),

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _Brand.forestGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Request Booking',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: _Brand.forestGreen,
    ),
  );

  Widget _buildPlacesPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _openPlacePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _Brand.forestGreenDark.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 16,
                  color: _Brand.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedPlaces.isEmpty
                        ? 'Choose places to include'
                        : '${_selectedPlaces.length} place${_selectedPlaces.length > 1 ? 's' : ''} selected',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: _Brand.forestGreen,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: _Brand.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (_selectedPlaces.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedPlaces.values.map((place) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: _Brand.forestGreenDark.withOpacity(0.1),
                  backgroundImage: place.imageUrl.isNotEmpty
                      ? NetworkImage(place.imageUrl)
                      : null,
                  child: place.imageUrl.isEmpty
                      ? const Icon(
                          Icons.place,
                          size: 12,
                          color: _Brand.forestGreen,
                        )
                      : null,
                ),
                label: Text(
                  place.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: _Brand.forestGreen,
                  ),
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: _Brand.forestGreenDark.withOpacity(0.15),
                ),
                deleteIcon: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: _Brand.textMuted,
                ),
                onDeleted: () =>
                    setState(() => _selectedPlaces.remove(place.id)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Future<void> _openPlacePicker() async {
    final places = await widget.placesFuture;
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PlacePickerSheet(
        places: places,
        initiallySelectedIds: _selectedPlaces.keys.toSet(),
        onDone: (selected) {
          setState(() {
            _selectedPlaces
              ..clear()
              ..addEntries(selected.map((p) => MapEntry(p.id, p)));
          });
        },
      ),
    );
  }

  Widget _buildPackageGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: TourPackage.values.map((pkg) {
        final isSelected = pkg == _package;
        return GestureDetector(
          onTap: () => setState(() => _package = pkg),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? _Brand.forestGreen : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? _Brand.forestGreen
                    : _Brand.forestGreenDark.withOpacity(0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  pkg.icon,
                  size: 20,
                  color: isSelected ? _Brand.amber : _Brand.forestGreen,
                ),
                const SizedBox(height: 6),
                Text(
                  pkg.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isSelected ? Colors.white : _Brand.forestGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pkg.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: isSelected ? Colors.white70 : _Brand.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dateTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _Brand.forestGreenDark.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: _Brand.amber,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      color: _Brand.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _Brand.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: _Brand.forestGreen,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: _Brand.textMuted,
        ),
        prefixIcon: Icon(icon, size: 16, color: _Brand.textMuted),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _Brand.forestGreenDark.withOpacity(0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _Brand.forestGreenDark.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _Brand.amber),
        ),
      ),
    );
  }

  Widget _passengerStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _Brand.forestGreenDark.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_outline_rounded,
            size: 16,
            color: _Brand.textMuted,
          ),
          const SizedBox(width: 8),
          const Text(
            'Passengers',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _Brand.forestGreen,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _passengers > 1
                ? () => setState(() => _passengers--)
                : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: _Brand.forestGreen,
            iconSize: 20,
          ),
          Text(
            '$_passengers',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          IconButton(
            onPressed: _passengers < 12
                ? () => setState(() => _passengers++)
                : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: _Brand.forestGreen,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _fareSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Brand.forestGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: _Brand.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated fare',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '$_tripDays day${_tripDays > 1 ? 's' : ''} · ₹${_package.ratePerDay}/day',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹$_estimatedFare',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// My Bookings tab
// ─────────────────────────────────────────────────────────────────────────

class _MyBookingsTab extends StatelessWidget {
  final Future<List<TourBooking>>? future;
  final Future<List<TouristPlace>> placesFuture;
  final VoidCallback onRefresh;

  const _MyBookingsTab({
    required this.future,
    required this.placesFuture,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TouristPlace>>(
      future: placesFuture,
      builder: (context, placesSnapshot) {
        final placesById = <String, TouristPlace>{
          for (final p in placesSnapshot.data ?? <TouristPlace>[]) p.id: p,
        };
        return _buildBookingsList(context, placesById);
      },
    );
  }

  Widget _buildBookingsList(
    BuildContext context,
    Map<String, TouristPlace> placesById,
  ) {
    return FutureBuilder<List<TourBooking>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _Brand.forestGreen),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Could not load bookings.\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _Brand.textMuted),
            ),
          );
        }

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.event_busy_rounded,
                    size: 40,
                    color: _Brand.textMuted,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: _Brand.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your tour and taxi bookings will show up here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: _Brand.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: _Brand.forestGreen,
          onRefresh: () async => onRefresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _BookingCard(booking: bookings[index], placesById: placesById),
          ),
        );
      },
    );
  }
}

class _PlacePickerSheet extends StatefulWidget {
  final List<TouristPlace> places;
  final Set<String> initiallySelectedIds;
  final ValueChanged<List<TouristPlace>> onDone;

  const _PlacePickerSheet({
    required this.places,
    required this.initiallySelectedIds,
    required this.onDone,
  });

  @override
  State<_PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends State<_PlacePickerSheet> {
  late Set<String> _selectedIds;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.initiallySelectedIds};
  }

  List<TouristPlace> get _filtered {
    if (_query.trim().isEmpty) return widget.places;
    final q = _query.toLowerCase();
    return widget.places
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _Brand.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Select places',
                        style: TextStyle(
                          fontFamily: 'Fraunces',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _Brand.forestGreen,
                        ),
                      ),
                    ),
                    Text(
                      '${_selectedIds.length} selected',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: _Brand.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search places',
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: _Brand.textMuted,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: _Brand.cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No places found',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: _Brand.textMuted,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final place = _filtered[index];
                          final isSelected = _selectedIds.contains(place.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (v) => setState(() {
                              if (v == true) {
                                _selectedIds.add(place.id);
                              } else {
                                _selectedIds.remove(place.id);
                              }
                            }),
                            activeColor: _Brand.forestGreen,
                            controlAffinity: ListTileControlAffinity.trailing,
                            secondary: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: place.imageUrl.isEmpty
                                    ? Container(
                                        color: _Brand.forestGreenDark
                                            .withOpacity(0.1),
                                      )
                                    : Image.network(
                                        place.imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            title: Text(
                              place.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _Brand.forestGreen,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final selected = widget.places
                            .where((p) => _selectedIds.contains(p.id))
                            .toList();
                        widget.onDone(selected);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Brand.forestGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Done (${_selectedIds.length})',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final TourBooking booking;
  final Map<String, TouristPlace> placesById;
  const _BookingCard({required this.booking, required this.placesById});

  Widget _buildPlacesRow() {
    final names = booking.placeIds
        .map((id) => placesById[id]?.name)
        .whereType<String>()
        .toList();
    if (names.isEmpty) return const SizedBox.shrink();

    final displayed = names.take(3).join(', ');
    final extra = names.length - 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.map_outlined, size: 12, color: _Brand.textMuted),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              extra > 0 ? '$displayed +$extra more' : displayed,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: _Brand.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Brand.forestGreenDark.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(booking.package.icon, size: 16, color: _Brand.forestGreen),
              const SizedBox(width: 6),
              Text(
                '${booking.package.label} Tour',
                style: const TextStyle(
                  fontFamily: 'Fraunces',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _Brand.forestGreen,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: booking.status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: booking.status.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: _Brand.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${dateFormat.format(booking.startDate)} – ${dateFormat.format(booking.endDate)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _Brand.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.people_outline_rounded,
                size: 12,
                color: _Brand.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${booking.passengers}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _Brand.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (booking.placeIds.isNotEmpty) _buildPlacesRow(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place_outlined, size: 12, color: _Brand.amber),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${booking.pickupLocation} → ${booking.dropLocation}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: _Brand.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booked ${DateFormat('d MMM, h:mm a').format(booking.createdAt)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: _Brand.textMuted,
                ),
              ),
              Text(
                '₹${booking.estimatedFare}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _Brand.forestGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
