import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  const AlarmRingScreen({super.key, required this.alarmSettings});
  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}
class _AlarmRingScreenState extends State<AlarmRingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  void _snooze(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Alarm.stop(widget.alarmSettings.id);
    final now = DateTime.now();
    final snoozeTime = now.add(const Duration(minutes: 5));
    final newSettings = widget.alarmSettings.copyWith(
      dateTime: snoozeTime,
    );
    await Alarm.set(alarmSettings: newSettings);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
  void _turnOff(BuildContext context) async {
    HapticFeedback.heavyImpact();
    await Alarm.stop(widget.alarmSettings.id);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFF2A2211), // Deep rich dark
              Color(0xFF0F0F0F), // Pure dark edges
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.15).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOutSine,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      size: 100,
                      color: const Color(0xFFD4AF37),
                      shadows: [
                        Shadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'REMINDER',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFC0A040), // Muted gold
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.alarmSettings.notificationSettings.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.alarmSettings.notificationSettings.body.isNotEmpty)
                  Text(
                    widget.alarmSettings.notificationSettings.body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _snooze(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'alarm.snooze'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _turnOff(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          elevation: 8,
                          shadowColor: const Color(0xFFD4AF37).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'alarm.turn_off'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
