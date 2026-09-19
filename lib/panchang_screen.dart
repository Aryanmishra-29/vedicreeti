import 'dart:ui';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'panchang_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'location_service.dart';
import 'package:shimmer/shimmer.dart';
import 'widgets/connection_lost_screen.dart';

enum PanchangDataState { loaded, skeleton, offlineError }
class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key});
  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}
class _PanchangScreenState extends State<PanchangScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late Future<Map<String, dynamic>> _panchangDataFuture;
  double? latitude;
  double? longitude;

  PanchangDataState _dataState = PanchangDataState.loaded;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _offlineTimer;

  @override
  void initState() {
    super.initState();
    LocationService.instance.currentPositionNotifier.addListener(_onLocationChanged);
    _onLocationChanged(); // initial set if already available
    _panchangDataFuture = PanchangService().fetchPanchangData(_selectedDate, lat: latitude, lon: longitude);
    _checkConnectivityAndListen();
  }

  void _checkConnectivityAndListen() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        if (_dataState != PanchangDataState.offlineError && _dataState != PanchangDataState.skeleton) {
          setState(() {
            _dataState = PanchangDataState.skeleton;
          });
          _offlineTimer?.cancel();
          _offlineTimer = Timer(const Duration(seconds: 7), () {
            if (mounted && _dataState == PanchangDataState.skeleton) {
              setState(() {
                _dataState = PanchangDataState.offlineError;
              });
            }
          });
        }
      } else {
        _offlineTimer?.cancel();
        if (_dataState != PanchangDataState.loaded) {
          setState(() {
            _dataState = PanchangDataState.skeleton;
          });
          
          _panchangDataFuture = PanchangService().fetchPanchangData(_selectedDate, lat: latitude, lon: longitude);
          _panchangDataFuture.then((_) {
            if (mounted) {
              setState(() {
                _dataState = PanchangDataState.loaded;
              });
            }
          }).catchError((_) {
             if (mounted) {
                setState(() {
                   _dataState = PanchangDataState.loaded;
                });
             }
          });
        }
      }
    });
  }
  void _onLocationChanged() {
    final pos = LocationService.instance.currentPositionNotifier.value;
    if (pos != null && mounted) {
      if (latitude != pos.latitude || longitude != pos.longitude) {
        setState(() {
          latitude = pos.latitude;
          longitude = pos.longitude;
          _panchangDataFuture = PanchangService().fetchPanchangData(_selectedDate, lat: latitude, lon: longitude);
        });
      }
    }
  }
  @override
  void dispose() {
    _offlineTimer?.cancel();
    _connectivitySubscription?.cancel();
    LocationService.instance.currentPositionNotifier.removeListener(_onLocationChanged);
    super.dispose();
  }
  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDate, selectedDay)) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedDate = selectedDay;
        _focusedDay = focusedDay;
        _panchangDataFuture = PanchangService().fetchPanchangData(_selectedDate, lat: latitude, lon: longitude);
      });
    }
  }
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
  Color get _textColor => _isDark ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D);
  Color get _mutedColor => _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6258);
  Widget _buildTableCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isDark ? const Color(0xFFC9922A).withOpacity(0.3) : const Color(0xFFE7D8B1), width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: TableCalendar(
        locale: context.locale.languageCode,
        firstDay: DateTime.utc(1900, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        availableGestures: AvailableGestures.horizontalSwipe,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: _onDateSelected,
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        rowHeight: 55.0 * MediaQuery.textScalerOf(context).scale(1.0),
        daysOfWeekHeight: 45.0,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false, titleCentered: true,
          titleTextStyle: TextStyle(color: Color(0xFFC9922A), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFC9922A)),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFC9922A)),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Color(0xFFC9922A), fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(color: Color(0xFFE8520A), fontWeight: FontWeight.bold),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(color: _textColor),
          weekendTextStyle: TextStyle(color: _mutedColor),
          outsideTextStyle: TextStyle(color: _mutedColor.withOpacity(0.5)),
          todayDecoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
          todayTextStyle: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
          selectedDecoration: BoxDecoration(
            color: const Color(0xFFC9922A).withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFC9922A), width: 1.5),
            boxShadow: [BoxShadow(color: const Color(0xFFC9922A).withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
          ),
          selectedTextStyle: const TextStyle(color: Color(0xFFC9922A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${day.day}',
                  style: TextStyle(color: _textColor),
                ),
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${day.day}',
                  style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFC9922A).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC9922A), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFFC9922A).withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Color(0xFFC9922A), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            );
          },
          outsideBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${day.day}',
                  style: TextStyle(color: _mutedColor.withOpacity(0.5)),
                ),
              ),
            );
          },
          dowBuilder: (context, day) {
            final text = DateFormat.E(context.locale.languageCode).format(day);
            final truncatedText = text.isNotEmpty ? text[0] : '';
            final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
            return Center(
              child: Text(
                truncatedText,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isWeekend ? const Color(0xFFE8520A) : const Color(0xFFE5C07B),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  String _extVal(dynamic f, String k) => (f is Map) ? (f['details']?[k]?.toString() ?? f['name']?.toString() ?? 'N/A') : (f?.toString() ?? 'N/A');
  Widget _buildGlassmorphicDataCard(Map<String, dynamic> data) {
    final apiData = data['output'] ?? data;
    final stats = [
      (Icons.wb_sunny_rounded, 'Sunrise', apiData['sun_rise']?.toString() ?? 'N/A', const Color(0xFFE8520A)),
      (Icons.nights_stay_rounded, 'Sunset', apiData['sun_set']?.toString() ?? 'N/A', const Color(0xFF8C9EFF)),
      (Icons.auto_awesome_rounded, 'Nakshatra', _extVal(apiData['nakshatra'], 'nakshatra_name'), const Color(0xFFC9922A)),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _bgColor, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _isDark ? const Color(0xFFC9922A).withOpacity(0.3) : const Color(0xFFE7D8B1), width: 0.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              Text('पंचांग विवरण', style: TextStyle(color: _mutedColor, fontSize: 14, letterSpacing: 1.0)),
              const SizedBox(height: 16),
              Text(_extVal(apiData['tithi'], 'tithi_name'), style: const TextStyle(color: Color(0xFFC9A227), fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.0), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: stats.expand((s) => [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(s.$1, color: s.$4, size: 28),
                        const SizedBox(height: 8),
                        Text(s.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _mutedColor, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(s.$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (s != stats.last) Container(width: 1, height: 40, color: const Color(0xFFC9922A).withOpacity(0.3)),
                ]).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMuhuratTimeline(Map<String, dynamic>? data) {
    final isValid = data != null && data['abhijit_muhurta'] != 'N/A';
    final items = [
      ('ui.abhijit_muhurat'.tr(), data?['abhijit_muhurta'], Colors.greenAccent, Icons.check_circle_outline),
      ('ui.rahu_kaal'.tr(), data?['rahu_kaal'], Colors.redAccent, Icons.warning_amber_rounded),
      ('ui.amrit_kaal'.tr(), data?['amrit_kaal'], Colors.blueAccent, Icons.star_border_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('शुभ मुहूर्त एवं राहुकाल', style: TextStyle(color: Color(0xFFC9922A), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 24),
        if (!isValid) const _GoldPulseLoading()
        else ...items.expand((item) => [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(shape: BoxShape.circle, color: item.$3.withOpacity(0.1), boxShadow: [BoxShadow(color: item.$3.withOpacity(0.4), blurRadius: 10, spreadRadius: 1)]),
                child: Icon(item.$4, color: item.$3, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1, style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(item.$2?.toString() ?? 'N/A', style: TextStyle(color: _mutedColor, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          if (item != items.last) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: _DashedDivider()),
        ]),
      ],
    );
  }
  Widget _buildOfflinePremiumWidget() {
    return ConnectionLostScreen(
      onRetry: () async {
        final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
        if (results.contains(ConnectivityResult.none)) {
          setState(() {
            _dataState = PanchangDataState.skeleton;
          });
          _offlineTimer?.cancel();
          _offlineTimer = Timer(const Duration(seconds: 7), () {
            if (mounted && _dataState == PanchangDataState.skeleton) {
              setState(() {
                _dataState = PanchangDataState.offlineError;
              });
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'ui.mystical_astro_dashboard'.tr(),
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE5C07B),
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: const Color(0xFFE5C07B).withOpacity(0.4),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true, iconTheme: const IconThemeData(color: Color(0xFF2A241D)),
      ),
      body: _dataState == PanchangDataState.offlineError
          ? _buildOfflinePremiumWidget()
          : _dataState == PanchangDataState.skeleton
              ? const PanchangSkeleton()
              : FutureBuilder<Map<String, dynamic>>(
        future: _panchangDataFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              const SizedBox(height: 16),
              _buildTableCalendar(),
              const SizedBox(height: 32),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: _GoldPulseLoading())
              else if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[800]!,
                    highlightColor: Colors.grey[600]!,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                )
              else ...[
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: _buildGlassmorphicDataCard(data!)),
                const SizedBox(height: 40),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: _buildMuhuratTimeline(data)),
                const SizedBox(height: 40),
              ],
            ],
          );
        },
      ),
    );
  }
}
class _GoldPulseLoading extends StatefulWidget {
  const _GoldPulseLoading();
  @override
  State<_GoldPulseLoading> createState() => _GoldPulseLoadingState();
}
class _GoldPulseLoadingState extends State<_GoldPulseLoading> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _a = Tween<double>(begin: 0.1, end: 0.4).animate(_c);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, _) => Container(
      width: double.infinity, height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFC9922A).withOpacity(_a.value),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC9922A).withOpacity(0.3)),
      ),
    ),
  );
}
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (c, constraints) => Flex(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, direction: Axis.horizontal,
      children: List.generate((constraints.constrainWidth() / 10).floor(), (_) => const SizedBox(width: 5, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFC9922A))))),
    ),
  );
}

class PanchangSkeleton extends StatelessWidget {
  const PanchangSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey.shade200,
      highlightColor: isDarkMode ? const Color(0xFF2A2211) : const Color(0xFFF9F6E8),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 16),
          // Date header (Calendar Skeleton)
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 32),
          // Sunrise/Sunset boxes (Data Card Skeleton)
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 40),
          // Tithi/Nakshatra list (Timeline Skeleton)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 24),
                for (int i = 0; i < 3; i++) ...[
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 18, width: 150, color: Colors.white),
                            const SizedBox(height: 8),
                            Container(height: 14, width: 100, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (i < 2) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white)),
                ]
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
