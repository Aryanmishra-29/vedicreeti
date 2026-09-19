import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'widgets/panchang_skeleton_card.dart';
import 'panchang_service.dart';
import 'location_service.dart';
class LivePanchangCard extends StatefulWidget {
  const LivePanchangCard({super.key});
  @override
  State<LivePanchangCard> createState() => _LivePanchangCardState();
}
class _LivePanchangCardState extends State<LivePanchangCard> {
  late Timer _timer;
  final ValueNotifier<DateTime> _currentTimeNotifier = ValueNotifier(DateTime.now());
  late Future<Map<String, dynamic>> _panchangDataFuture;
  double? latitude;
  double? longitude;
  @override
  void initState() {
    super.initState();
    LocationService.instance.currentPositionNotifier.addListener(_onLocationChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationService.instance.startLocationTracking(context);
    });
    _panchangDataFuture = fetchPanchangData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _currentTimeNotifier.value = DateTime.now();
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
          _panchangDataFuture = fetchPanchangData();
        });
      }
    }
  }
  @override
  void dispose() {
    _timer.cancel();
    _currentTimeNotifier.dispose();
    LocationService.instance.currentPositionNotifier.removeListener(_onLocationChanged);
    super.dispose();
  }
  Future<Map<String, dynamic>> fetchPanchangData() async {
    return PanchangService().fetchPanchangData(DateTime.now(), lat: latitude, lon: longitude);
  }
  String _formatTime(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    String h = hour.toString().padLeft(2, '0');
    String m = time.minute.toString().padLeft(2, '0');
    String s = time.second.toString().padLeft(2, '0');
    return "$h:$m:$s $period";
  }
  String _formatDate(DateTime time) {
    const months = [
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String dayName = days[time.weekday - 1];
    String monthName = months[time.month - 1];
    return "$dayName, ${time.day} $monthName ${time.year}";
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8520A).withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7B1C1C).withOpacity(0.85), // Deep Maroon
                  const Color(
                    0xFF0A0E27,
                  ).withOpacity(0.85), // Dark Midnight Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFC9922A).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: ValueListenableBuilder<DateTime>(
                              valueListenable: _currentTimeNotifier,
                              builder: (context, currentTime, child) {
                                return Text(
                                  _formatDate(currentTime),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.0,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: ValueListenableBuilder<DateTime>(
                              valueListenable: _currentTimeNotifier,
                              builder: (context, currentTime, child) {
                                return RepaintBoundary( // Isolate repaint boundary for ticking text
                                  child: SizedBox(
                                    width: 240, // strictly defined width to stop horizontal jitter
                                    child: Text(
                                      _formatTime(currentTime),
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                      style: const TextStyle(
                                        fontFamily: 'Courier', // Monospace fallback to prevent proportional shift
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        fontFeatures: [FontFeature.tabularFigures()], // Uniform digit widths
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded),
                              color: const Color(0xFFC9922A).withOpacity(0.8),
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                LocationService.instance.forceRefreshLocation(context);
                              },
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.location_on_rounded,
                              color: const Color(0xFFC9922A).withOpacity(0.8),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            latitude != null ? "Lat: ${latitude!.toStringAsFixed(4)}" : "Lat: --",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            longitude != null ? "Lon: ${longitude!.toStringAsFixed(4)}" : "Lon: --",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                  ],
                    ),
                ), // End Row for clock
                const SizedBox(height: 24),
                FutureBuilder<Map<String, dynamic>>(
                  future: _panchangDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: double.infinity,
                        child: PanchangCardSkeleton(),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE8520A).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              color: Color(0xFFE8520A),
                              size: 36,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Live Data Unavailable',
                              style: TextStyle(
                                color: Color(0xFFC9922A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Serif',
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Panchang data syncing...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final data = snapshot.data!;
                    final tithi = data['tithi']?.toString() ?? 'N/A';
                    final nakshatra = data['nakshatra']?.toString() ?? 'N/A';
                    final sunrise = data['sun_rise']?.toString() ?? 'N/A';
                    final sunset = data['sun_set']?.toString() ?? 'N/A';
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFC9922A).withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'आज की तिथि',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    tithi,
                                    style: const TextStyle(
                                      color: Color(0xFFC9922A), // Prominent Gold
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                      fontFamily: 'Noto Sans Devanagari',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildAstroItem(
                                  Icons.wb_sunny_rounded,
                                  'Sunrise',
                                  sunrise,
                                  const Color(0xFFE8520A),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: const Color(0xFFC9922A).withOpacity(0.3),
                              ),
                              Expanded(
                                child: _buildAstroItem(
                                  Icons.nights_stay_rounded,
                                  'Sunset',
                                  sunset,
                                  const Color(0xFF8C9EFF),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: const Color(0xFFC9922A).withOpacity(0.3),
                              ),
                              Expanded(
                                child: _buildAstroItem(
                                  Icons.auto_awesome_rounded,
                                  'Nakshatra',
                                  nakshatra,
                                  const Color(0xFFC9922A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildAstroItem(
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
