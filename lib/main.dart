import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'reminder_service.dart';
import 'wishlist_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/wishlist_screen.dart';
import 'screens/update_password_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'screens/alarm_ring_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'cache_service.dart';
import 'services/notification_service.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(CacheService.boxName);
  await Hive.openBox('remindersBox');
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme_mode');
  if (savedTheme == 'light') {
    themeNotifier.value = ThemeMode.light;
  } else if (savedTheme == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  } else {
    themeNotifier.value = ThemeMode.system;
  }
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  await ReminderService().init();
  await NotificationService().init();
  await Alarm.init();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase config not found: ');
  }
  WishlistService.instance;
  runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('mr'),
          Locale('gu'),
          Locale('bn'),
          Locale('ta'),
          Locale('te'),
          Locale('kn'),
          Locale('ml'),
          Locale('pa'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        child: const VedicReetiApp(),
      ),
  );
}
class VedicReetiApp extends StatefulWidget {
  const VedicReetiApp({super.key});
  @override
  State<VedicReetiApp> createState() => _VedicReetiAppState();
}
class _VedicReetiAppState extends State<VedicReetiApp> {
  late final StreamSubscription<AuthState> _authSubscription;
  late final StreamSubscription<AlarmSettings>? _alarmSubscription;
  @override
  void initState() {
    super.initState();
    _setupFCMListeners();
    _setupAuthListener();
    _setupAlarmListener();
  }
  void _setupAlarmListener() {
    _alarmSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(alarmSettings: alarmSettings),
        ),
      );
    });
  }
  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const UpdatePasswordScreen()),
        );
      }
    });
  }
  @override
  void dispose() {
    _authSubscription.cancel();
    _alarmSubscription?.cancel();
    super.dispose();
  }
  void _setupFCMListeners() async {
    try {
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null && initialMessage.data['route'] == '/wishlist') {
        Future.delayed(const Duration(milliseconds: 500), () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const WishlistScreen()),
          );
        });
      }
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data['route'] == '/wishlist') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const WishlistScreen()),
          );
        }
      });
    } catch (e) {
      debugPrint('FCM not initialized properly: ');
    }
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'VedicReeti',
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            return MediaQuery.withClampedTextScaling(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.25,
              child: child,
            );
          },
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFFAF7F2), // Primary Background
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFC9A227), // Premium Gold
              primary: const Color(0xFFC9A227),
              surface: const Color(0xFFFFFFFF), // Card Background
              background: const Color(0xFFFAF7F2),
              brightness: Brightness.light,
            ),
            cardColor: const Color(0xFFFFFFFF),
            splashColor: const Color(0xFFC9A227).withOpacity(0.15),
            highlightColor: Colors.transparent,
            textTheme: _buildTextTheme(const Color(0xFF6B6258), const Color(0xFF2A241D)),
            useMaterial3: true,
          ),
          darkTheme: ThemeData( // Proper Midnight Dark Mode
            scaffoldBackgroundColor: const Color(0xFF0A0A0C),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD4AF37),
              primary: const Color(0xFFD4AF37),
              surface: const Color(0xFF141416),
              background: const Color(0xFF0A0A0C),
              brightness: Brightness.dark,
            ),
            cardColor: const Color(0xFF141416),
            splashColor: const Color(0xFFD4AF37).withOpacity(0.15),
            highlightColor: Colors.transparent,
            textTheme: _buildTextTheme(Colors.white.withOpacity(0.8), const Color(0xFFD4AF37)),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
  TextTheme _buildTextTheme(Color bodyColor, Color displayColor) {
    return GoogleFonts.notoSansTextTheme().apply(
      bodyColor: bodyColor,
      displayColor: displayColor,
    );
  }
}
