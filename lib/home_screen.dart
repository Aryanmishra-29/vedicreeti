import 'dart:ui';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'cache_service.dart';
import 'utils/localization_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:just_audio/just_audio.dart';
import 'live_panchang_card.dart';
import 'puja_booking_screen.dart';
import 'panchang_screen.dart';
import 'profile_screen.dart';
import 'retail_screen.dart';
import 'screens/devotional_category_screen.dart';
import 'global_audio_service.dart';
import 'screens/devotional_audio_player_screen.dart';
import 'reminder_service.dart';
import 'package:shimmer/shimmer.dart';
import 'auth_bottom_sheet.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alarm/alarm.dart';
import 'screens/product_detail_screen.dart';
import 'widgets/about_us_dialog.dart';
import 'widgets/premium_skeleton_card.dart';
import 'widgets/banner_skeleton_card.dart';
import 'widgets/product_skeleton_grid.dart';
import 'widgets/luxury_skeleton_card.dart';
import 'widgets/connection_lost_screen.dart';
import 'about_app_screen.dart';
import 'main.dart'; // REQUIRED for themeNotifier
import 'domain/repositories/product_repository.dart';
import 'services/notification_service.dart';

enum DataState { loaded, skeleton, offlineError }

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  final bool _hasAudioStarted = false;
  late final AudioPlayer _audioPlayer;
  int _currentBannerIndex = 0;
  bool _isNavigating = false;
  late Future<List<Map<String, dynamic>>> _featuredProductsFuture;
  late Future<List<Map<String, dynamic>>> _allProductsFuture;
  late Future<List<Map<String, dynamic>>> _upcomingFestivalsFuture;
  late Future<List<Map<String, dynamic>>> _premiumPujasFuture;

  DataState _dataState = DataState.loaded;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _offlineTimer;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _audioPlayer = AudioPlayer();
    _initAudio();
    _featuredProductsFuture = _fetchFeaturedProducts();
    _allProductsFuture = _fetchAllProducts();
    _upcomingFestivalsFuture = _fetchUpcomingFestivals();
    _premiumPujasFuture = _fetchPremiumPujas();
    _checkConnectivityAndListen();
    NotificationService().requestNotificationPermissions();
  }
  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setAsset('assets/audio/flute.mp3');
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }
  @override
  void dispose() {
    _offlineTimer?.cancel();
    _connectivitySubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _checkConnectivityAndListen() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        if (_dataState != DataState.offlineError && _dataState != DataState.skeleton) {
          setState(() {
            _dataState = DataState.skeleton;
          });
          _offlineTimer?.cancel();
          _offlineTimer = Timer(const Duration(seconds: 7), () {
            if (mounted && _dataState == DataState.skeleton) {
              setState(() {
                _dataState = DataState.offlineError;
              });
            }
          });
        }
      } else {
        _offlineTimer?.cancel();
        if (_dataState != DataState.loaded) {
          setState(() {
            _dataState = DataState.skeleton;
          });
          
          _featuredProductsFuture = _fetchFeaturedProducts();
          _allProductsFuture = _fetchAllProducts();
          _upcomingFestivalsFuture = _fetchUpcomingFestivals();
          _premiumPujasFuture = _fetchPremiumPujas();
          
          Future.wait([
            _featuredProductsFuture,
            _allProductsFuture,
            _upcomingFestivalsFuture,
            _premiumPujasFuture,
          ]).then((_) {
            if (mounted) {
              setState(() {
                _dataState = DataState.loaded;
              });
            }
          }).catchError((_) {
             if (mounted) {
                setState(() {
                   _dataState = DataState.loaded;
                });
             }
          });
        }
      }
    });
  }
  Future<void> _navigateToProduct(String productId) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
    if (mounted) setState(() => _isNavigating = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent, // Background handled by Container
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: SafeArea(
          bottom: true,
          child: Stack(
            children: [
              _buildCurrentScreen(context),
              _buildMiniPlayer(),
            ],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  Widget _buildCurrentScreen(BuildContext context) {
    if (_dataState == DataState.offlineError) {
      return _buildOfflinePremiumWidget();
    }

    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(context);
      case 1:
        return const PanchangScreen();
      case 2:
        return const RetailScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent(context);
    }
  }

  Widget _buildOfflinePremiumWidget() {
    return ConnectionLostScreen(
      onRetry: () async {
        final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
        if (results.contains(ConnectivityResult.none)) {
          setState(() {
            _dataState = DataState.skeleton;
          });
          _offlineTimer?.cancel();
          _offlineTimer = Timer(const Duration(seconds: 7), () {
            if (mounted && _dataState == DataState.skeleton) {
              setState(() {
                _dataState = DataState.offlineError;
              });
            }
          });
        }
      },
    );
  }

  Widget _buildMiniPlayer() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: GlobalAudioService().currentItemNotifier,
      builder: (context, item, child) {
        if (item == null) return const SizedBox.shrink();
        return Positioned(
          left: 16,
          right: 16,
          bottom: 16, // Hovering right above the bottom nav bar
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => DevotionalAudioPlayerScreen(audioItem: item),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE7D8B1), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10, offset: const Offset(0, 4)
                      )
                    ]
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item['image_url'] != null && item['image_url'].toString().startsWith('http')
                            ? Image.network(item['image_url'].toString(), width: 48, height: 48, fit: BoxFit.cover)
                            : Image.asset(item['image_url']?.toString() ?? 'assets/images/god_ganesh.jpg', width: 48, height: 48, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                item['title']?.toString() ?? 'Unknown Title',
                                style: const TextStyle(
                                  color: Color(0xFF2A241D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Noto Sans Devanagari',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                item['subtitle']?.toString() ?? 'Traditional',
                                style: const TextStyle(
                                  color: Color(0xFF6B6258),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: GlobalAudioService().isPlayingNotifier,
                        builder: (context, isPlaying, child) {
                          return IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: const Color(0xFFC9A227),
                              size: 28,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              GlobalAudioService().togglePlayPause();
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF6B6258)),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          GlobalAudioService().stopAndDismiss();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildHomeContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 380, maxHeight: 450), // Prevent async image loading and carousel repaints from pushing layout
                  child: _buildFeaturedProductsSlider(),
                ),
                const SizedBox(height: 32),
                _buildAllProductsSection(context),
                const SizedBox(height: 32),
                const LivePanchangCard(),
                const SizedBox(height: 48),
                _buildRemindersSection(),
                const SizedBox(height: 48),
                _buildPremiumFestivalsSection(),
                const SizedBox(height: 48),
                _buildQuickPujaSection(context),
                const SizedBox(height: 48),
                _buildPremiumPujasSection(),
                const SizedBox(height: 56),
                _buildDeveloperCredit(),
                const SizedBox(
                  height: 120,
                ), // Padding to prevent bottom nav bar overlap
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/app_icon.png',
              height: 38,
              width: 38,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'VedicReeti',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const Spacer(),
          PopupMenuButton<ThemeMode>(
            icon: Icon(
              themeNotifier.value == ThemeMode.light ? Icons.light_mode :
              themeNotifier.value == ThemeMode.dark ? Icons.dark_mode : Icons.brightness_auto,
              color: Theme.of(context).colorScheme.primary,
            ),
            onSelected: (ThemeMode mode) async {
              themeNotifier.value = mode;
              final prefs = await SharedPreferences.getInstance();
              if (mode == ThemeMode.light) {
                await prefs.setString('theme_mode', 'light');
              } else if (mode == ThemeMode.dark) {
                await prefs.setString('theme_mode', 'dark');
              } else {
                await prefs.setString('theme_mode', 'system');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<ThemeMode>(
                  value: ThemeMode.light,
                  child: Row(children: [Icon(Icons.light_mode, size: 18), SizedBox(width: 8), Text('Light Mode')]),
                ),
                const PopupMenuItem<ThemeMode>(
                  value: ThemeMode.dark,
                  child: Row(children: [Icon(Icons.dark_mode, size: 18), SizedBox(width: 8), Text('Dark Mode')]),
                ),
                const PopupMenuItem<ThemeMode>(
                  value: ThemeMode.system,
                  child: Row(children: [Icon(Icons.brightness_auto, size: 18), SizedBox(width: 8), Text('System Default')]),
                ),
              ];
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
            onSelected: (value) {
              debugPrint('Selected menu item: $value');
              if (value == 'about_us') {
                showDialog(context: context, builder: (_) => const AboutUsDialog());
              } else if (value == 'about_app') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAppScreen()));
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'contact',
                  child: Text('Contact Us'),
                ),
                const PopupMenuItem<String>(
                  value: 'about_us',
                  child: Text('About Us'),
                ),
                const PopupMenuItem<String>(
                  value: 'about_app',
                  child: Text('About App'),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
  Future<List<Map<String, dynamic>>> _fetchFeaturedProducts() async {
    return await ProductRepository.fetchFeaturedProducts();
  }
  Widget _buildFeaturedProductsSlider() {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box(CacheService.boxName).listenable(keys: ['featured_products']),
      builder: (context, box, _) {
        final cachedData = box.get('featured_products');
        final products = (cachedData as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
        if (_dataState == DataState.skeleton || products.isEmpty) {
          return const FeaturedCarouselSkeleton();
        }
        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: products.length,
              options: CarouselOptions(
                height: 350.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                enlargeCenterPage: true,
                viewportFraction: 0.92,
                aspectRatio: 16 / 9,
                enableInfiniteScroll: products.length > 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
              ),
              itemBuilder: (BuildContext context, int index, int realIndex) {
                final product = products[index];
                String imageUrl = '';
                final imgs = product['images'];
                if (imgs is List && imgs.isNotEmpty) {
                  imageUrl = imgs[0].toString();
                } else if (imgs is String && imgs.isNotEmpty) {
                  imageUrl = imgs;
                } else if (product['image_url'] != null) {
                  imageUrl = product['image_url'].toString();
                }
                if (imageUrl.isNotEmpty && !imageUrl.startsWith('http') && product['is_asset'] != true) {
                  imageUrl = Supabase.instance.client.storage.from('products').getPublicUrl(imageUrl);
                }
                final String productId = product['product_id']?.toString() ?? product['id']?.toString() ?? '';
                final bool isAsset = product['is_asset'] == true;
                String name = getLocalizedText(product['name'] ?? product['title'], context.locale.languageCode);
                if (name.isEmpty) name = 'Featured Product';
                String description = getLocalizedText(product['description'], context.locale.languageCode);
                if (description.isEmpty) description = 'Exclusive luxury collection';
                final num price = product['sale_price'] ?? product['price'] ?? 0;
                final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                final bgColor = isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFDFBF7);
                final borderColor = isDarkMode ? const Color(0xFFC5A880).withOpacity(0.3) : const Color(0xFFD4AF37).withOpacity(0.3);
                final headlineColor = isDarkMode ? const Color(0xFFFDFBF7) : const Color(0xFF1A1A1A);
                final subtitleColor = isDarkMode ? const Color(0xFFC5A880) : const Color(0xFF4A3B32).withOpacity(0.8);
                final priceLabelColor = isDarkMode ? Colors.white.withOpacity(0.6) : const Color(0xFF1A1A1A).withOpacity(0.6);
                final badgeBorderColor = isDarkMode ? const Color(0xFFC5A880).withOpacity(0.5) : const Color(0xFFD4AF37).withOpacity(0.5);
                final featuredBadgeTextColor = isDarkMode ? const Color(0xFF38BDF8) : Colors.blue[600]!;
                final featuredBadgeBgColor = isDarkMode ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.blue[600]!.withOpacity(0.1);
                final featuredBadgeBorderColor = isDarkMode ? const Color(0xFF60A5FA).withOpacity(0.3) : Colors.blue[600]!.withOpacity(0.5);
                return GestureDetector(
                  onTap: () {
                    if (productId.isNotEmpty) {
                      _navigateToProduct(productId);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.6) : const Color(0xFFD4AF37).withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFD4AF37).withOpacity(0.2),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Frosted glass effect
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? const Color(0xFFD4AF37).withOpacity(0.1)
                                                : const Color(0xFFD4AF37).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFFD4AF37).withOpacity(0.8),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.auto_awesome,
                                                color: const Color(0xFFD4AF37),
                                                size: 14,
                                                shadows: [
                                                  Shadow(
                                                    color: const Color(0xFFD4AF37).withOpacity(0.6),
                                                    blurRadius: 8,
                                                  )
                                                ],
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'ui.exclusive_offer'.tr(),
                                                  style: TextStyle(
                                                    color: isDarkMode ? const Color(0xFFFFD700) : const Color(0xFFB8860B),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.0,
                                                    shadows: isDarkMode ? [
                                                      Shadow(
                                                        color: const Color(0xFFD4AF37).withOpacity(0.5),
                                                        blurRadius: 6,
                                                      )
                                                    ] : null,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: headlineColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Playfair Display',
                                      letterSpacing: 1.0,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      height: 1.4,
                                    )
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('PRICE', style: TextStyle(color: priceLabelColor, fontSize: 8, letterSpacing: 1.0)),
                                          Text('₹${price.toStringAsFixed(0)}', style: TextStyle(color: headlineColor, fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD4AF37),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${'ui.explore'.tr()} →',
                                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: isAsset
                                              ? Image.asset(
                                                  imageUrl.isNotEmpty ? imageUrl : 'assets/images/app_icon.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : imageUrl.isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl: imageUrl,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) => Shimmer.fromColors(
                                                        baseColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
                                                        highlightColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF424242) : Colors.grey.shade50,
                                                        child: Container(color: Colors.white),
                                                      ),
                                                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white54),
                                                    )
                                                  : const Icon(Icons.image, color: Colors.white54),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const RadialGradient(colors: [Color(0xFFF9E79F), Color(0xFFD4AF37), Color(0xFFAA7C11)], stops: [0.2, 0.7, 1.0]),
                                            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))],
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.spa_rounded, color: Color(0xFF4A3B32), size: 8),
                                                const SizedBox(height: 1),
                                                const Text('CERTIFIED', style: TextStyle(fontSize: 3.5, color: Color(0xFF4A3B32), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: products.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentBannerIndex == entry.key ? 24.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: _currentBannerIndex == entry.key
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFD4AF37).withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
  Widget _buildTrustBadge(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 6, color: color),
        const SizedBox(width: 2),
        Text(label, style: TextStyle(color: color, fontSize: 4, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ],
    );
  }
  Future<List<Map<String, dynamic>>> _fetchAllProducts() async {
    return await ProductRepository.fetchAllProducts();
  }
  Widget _buildAllProductsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ui.all_products'.tr(),
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
          ],
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 405, maxHeight: 480), // Increased from 390 to prevent overflow
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _allProductsFuture,
            builder: (context, snapshot) {
              final isSkeleton = _dataState == DataState.skeleton || 
                  snapshot.connectionState == ConnectionState.waiting || 
                  snapshot.hasError || 
                  !snapshot.hasData || 
                  (snapshot.data ?? []).isEmpty;
                  
              if (isSkeleton) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemCount: 4,
                  separatorBuilder: (context, index) => const SizedBox(width: 20),
                  itemBuilder: (context, index) => const HorizontalProductSkeleton(),
                );
              }
              
              final products = snapshot.data ?? [];
              return ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  return _buildHorizontalProductCard(context, products[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildHorizontalProductCard(BuildContext context, Map<String, dynamic> product) {
    String name = getLocalizedText(product['name'], context.locale.languageCode);
    if (name.isEmpty) name = 'Product';
    String desc = getLocalizedText(product['description'], context.locale.languageCode);
    if (desc.isEmpty) desc = 'Premium Quality';
    String imageUrl = '';
    final imgs = product['images'];
    if (imgs is List && imgs.isNotEmpty) {
      imageUrl = imgs[0].toString();
    } else if (imgs is String && imgs.isNotEmpty) {
      imageUrl = imgs;
    } else if (product['image_url'] != null) {
      imageUrl = product['image_url'].toString();
    }
    final num price = product['sale_price'] ?? product['price'] ?? 0;
    final String productId = product['id']?.toString() ?? '';
    return GestureDetector(
      onTap: () {
        if (productId.isNotEmpty) {
          _navigateToProduct(productId);
        }
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF151515) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE7D8B1).withOpacity(0.8), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: "home_product_image_\$productId",
                    child: Material(
                      color: Colors.transparent,
                      child: (imageUrl.isNotEmpty)
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, _) => _buildGlowingPlaceholder(context),
                            )
                          : _buildGlowingPlaceholder(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Serif',
                              color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF2A241D) : Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.5),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '₹${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6258),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC9A227), Color(0xFFE7D8B1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC9A227).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${'ui.explore'.tr()} →',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildQuickPujaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  'ui.quick_puja_mantras'.tr(),
                  maxLines: 1,
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
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 170, // Increased height for compact categorical cards
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            children: [
              _buildCategoryCard(
                title: 'ui.aarti'.tr(),
                subtitle: 'ui.view_all_aartis'.tr(),
                topIcon: Icons.local_fire_department_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DevotionalCategoryScreen(categoryType: 'Aarti'),
                    ),
                  );
                },
              ),
              _buildCategoryCard(
                title: 'ui.chalisa'.tr(),
                subtitle: 'ui.view_all_chalisas'.tr(),
                topIcon: Icons.menu_book_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DevotionalCategoryScreen(categoryType: 'Chalisa'),
                    ),
                  );
                },
              ),
              _buildCategoryCard(
                title: 'ui.mantras'.tr(),
                subtitle: 'ui.view_all_mantras'.tr(),
                topIcon: Icons.spa_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DevotionalCategoryScreen(categoryType: 'Mantra'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData topIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170.0,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: const Color(0xFFE7D8B1), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(topIcon, color: const Color(0xFFC9A227), size: 28.0),
                const SizedBox(height: 16.0),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF1A1A1A) : Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4.0),
                Flexible(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF6B6258) : Colors.white70, fontSize: 11.0),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE7D8B1), width: 0.5),
                ),
                child: const Icon(Icons.chevron_right_rounded, color: Color(0xFFC9A227), size: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<List<Map<String, dynamic>>> _fetchPremiumPujas() async {
    try {
      final response = await Supabase.instance.client.from('services').select();
      return (response as List).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetching premium pujas: $e');
      return [];
    }
  }
  Widget _buildPremiumPujasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  'ui.premium_puja_services'.tr(),
                  maxLines: 1,
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
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 380, // Increased from 350
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _premiumPujasFuture,
            builder: (context, snapshot) {
              final isSkeleton = _dataState == DataState.skeleton || 
                  snapshot.connectionState == ConnectionState.waiting || 
                  snapshot.hasError || 
                  !snapshot.hasData;
              if (isSkeleton) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemCount: 3,
                  separatorBuilder: (context, index) => const SizedBox(width: 20),
                  itemBuilder: (context, index) => const PremiumPujaSkeleton(),
                );
              }
              final pujas = snapshot.data ?? [];
              if (pujas.isEmpty) {
                return const Center(child: Text('No premium pujas found', style: TextStyle(color: Colors.white54)));
              }
              return ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: pujas.length,
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  return _buildHorizontalPujaCard(context, pujas[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildHorizontalPujaCard(BuildContext context, Map<String, dynamic> puja) {
    String name = getLocalizedText(puja['name'], context.locale.languageCode);
    if (name.isEmpty) name = 'Premium Service';
    String desc = getLocalizedText(puja['description'], context.locale.languageCode);
    if (desc.isEmpty) desc = 'Authentic Vedic Ritual';
    final String? imageUrl = puja['image_url']?.toString();
    final double price = puja['price'] != null
        ? (puja['price'] is num
              ? (puja['price'] as num).toDouble()
              : double.tryParse(puja['price'].toString()) ?? 5100.0)
        : 5100.0;
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7D8B1).withOpacity(0.8), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: "home_puja_image_${puja['id'] ?? name}",
                  child: Material(
                    color: Colors.transparent,
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, _) => _buildGlowingPlaceholder(context),
                          )
                        : _buildGlowingPlaceholder(context),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Theme.of(context).brightness == Brightness.light ? const Color(0xFFFFFFFF).withOpacity(0.8) : const Color(0xFF1E1E1E).withOpacity(0.8),
                        Theme.of(context).brightness == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF1E1E1E),
                      ],
                      stops: const [0.4, 0.8, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Serif',
                            color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF1A1A1A) : const Color(0xFFFDFBF7),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.5),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '₹${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF6B6258) : const Color(0xFFB0B0B0),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user == null) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const AuthBottomSheet(),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LuxuryStepperScreen(
                              pujaName: name,
                              pujaPrice: price,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC9A227), Color(0xFFE7D8B1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC9A227).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text('ui.book_now'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
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
  Widget _buildGlowingPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFFDFBF7) : const Color(0xFF1A1A1D),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: const Icon(
            Icons.self_improvement_rounded,
            size: 40,
            color: Color(0xFFD4AF37),
          ),
        ),
      ),
    );
  }
  Widget _buildDeveloperCredit() {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: SafeArea(
        bottom: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 1,
                color: const Color(0xFFD4AF37).withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'ui.app_developed_by'.tr(),
                  style: TextStyle(
                    color: const Color(0xFFD4AF37).withOpacity(0.6), // Muted Gold
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                    fontFamily: 'Serif',
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
  Future<List<Map<String, dynamic>>> _fetchUpcomingFestivals() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await Supabase.instance.client
          .from('upcoming_festivals')
          .select('*')
          .gte('date', today)
          .order('date', ascending: true);
      return (response as List).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetching upcoming festivals: $e');
      return [];
    }
  }
  String _calculateUrgency(String dateStr) {
    try {
      final festivalDate = DateTime.parse(dateStr);
      final today = DateTime.now();
      final diff = DateTime(festivalDate.year, festivalDate.month, festivalDate.day)
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      if (diff == 0) return 'आज';
      if (diff == 1) return 'कल';
      return '$diff दिन बाकी';
    } catch (e) {
      return '';
    }
  }
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🚨 Error Detector Active"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }
  void _showPujaVidhiBottomSheet(String title, String? content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFD4AF37),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFFD4AF37)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Noto Sans Devanagari',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      content ?? 'पूजा विधि उपलब्ध नहीं है।',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.8,
                        fontFamily: 'Noto Sans Devanagari',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showAddReminderBottomSheet(BuildContext context, {Map<String, dynamic>? existingReminder}) {
    final titleController = TextEditingController(text: existingReminder?['title']?.toString() ?? '');
    DateTime selectedDateTime = DateTime.now();
    if (existingReminder != null && existingReminder['time'] != null) {
      final parsed = DateTime.tryParse(existingReminder['time'].toString())?.toLocal();
      if (parsed != null) selectedDateTime = parsed;
    }
    String? customAudioPath = existingReminder?['customAudioPath']?.toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    existingReminder != null ? 'Edit Reminder' : 'Add New Reminder',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    decoration: InputDecoration(
                      hintText: 'Enter reminder title...',
                      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                      filled: true,
                      fillColor: Theme.of(context).dividerColor.withOpacity(0.05),
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFFD4AF37)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: selectedDateTime,
                        onDateTimeChanged: (DateTime newDateTime) {
                          setModalState(() {
                            selectedDateTime = DateTime(
                              selectedDateTime.year,
                              selectedDateTime.month,
                              selectedDateTime.day,
                              newDateTime.hour,
                              newDateTime.minute,
                            );
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Ringtone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      try {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.audio,
                          allowMultiple: false,
                        );
                        if (result != null && result.files.single.path != null) {
                          setModalState(() {
                            customAudioPath = result.files.single.path!;
                          });
                        }
                      } catch (e) {
                        debugPrint('File picker error: $e');
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.music_note_rounded, color: Color(0xFFD4AF37), size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              customAudioPath != null && customAudioPath!.isNotEmpty
                                  ? customAudioPath!.split('/').last
                                  : 'Default Ringtone',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (customAudioPath != null && customAudioPath!.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  customAudioPath = null;
                                });
                              },
                              child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                            )
                          else
                            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                        elevation: 4,
                        shadowColor: const Color(0xFFD4AF37).withOpacity(0.5),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
                      label: Text(
                        existingReminder != null ? 'Update Reminder' : 'Set Reminder',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) {
                          _showErrorDialog(context, 'Please enter title');
                          return;
                        }
                        bool hasPermission = await ReminderService().hasNotificationPermission();
                        if (!hasPermission && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You won\'t be able to see or receive your reminders unless you enable notifications. Please turn on notifications in your system settings.', style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                        try {
                          String reminderId = await ReminderService().saveLocalReminder(
                            titleController.text.trim(),
                            selectedDateTime,
                            customAudioPath: customAudioPath,
                            existingId: existingReminder?['id']?.toString(),
                          );
                          int notificationId = reminderId.hashCode;
                          await ReminderService().scheduleExactReminder(
                            notificationId,
                            title,
                            "It's time for your reminder!",
                            selectedDateTime,
                            customAudioPath: customAudioPath,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder Saved!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                backgroundColor: Color(0xFFD4AF37),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            _showErrorDialog(context, 'Error inserting reminder: $e');
                          }
                        }
                      },
                    ),
                  ),
                  if (existingReminder != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          final reminderId = existingReminder['id']?.toString();
                          if (reminderId != null) {
                            await ReminderService().deleteLocalReminder(reminderId);
                            await Alarm.stop(reminderId.hashCode);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reminder Deleted!', style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Delete Reminder', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildRemindersSection() {
    final user = Supabase.instance.client.auth.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ui.active_reminders'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
              ],
            ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
              onPressed: () => _showAddReminderBottomSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ValueListenableBuilder<Box>(
          valueListenable: Hive.box('remindersBox').listenable(),
          builder: (context, box, _) {
            final reminders = ReminderService().getLocalReminders();
            if (reminders.isEmpty) {
              return Container(
                constraints: const BoxConstraints(minHeight: 180),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: _BreathingReminderIcon(
                  onTap: () => _showAddReminderBottomSheet(context),
                ),
              );
            }
            return Column(
              children: reminders.map((reminder) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () => _showAddReminderBottomSheet(context, existingReminder: reminder),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFFC9A227),
                      size: 28,
                    ),
                    title: Text(
                      reminder['title']?.toString() ?? 'Reminder',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        (() {
                          try {
                            final rawDate = reminder['time']?.toString() ?? '';
                            if (rawDate.isEmpty) return '';
                            final dt = DateTime.parse(rawDate).toLocal();
                            return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
                          } catch (_) {
                            return reminder['time']?.toString() ?? '';
                          }
                        })(),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      value: reminder['isActive'] ?? true,
                      activeTrackColor: const Color(0xFFD4AF37),
                      onChanged: (value) async {
                        HapticFeedback.lightImpact();
                        final reminderId = reminder['id']?.toString();
                        if (reminderId == null) return;
                        await ReminderService().toggleReminderActive(reminderId, value);
                        if (value) {
                          final title = reminder['title']?.toString() ?? 'Reminder';
                          final timeStr = reminder['time']?.toString() ?? '';
                          if (timeStr.isNotEmpty) {
                            final time = DateTime.tryParse(timeStr)?.toLocal();
                            if (time != null && time.isAfter(DateTime.now())) {
                              await ReminderService().scheduleExactReminder(
                                reminderId.hashCode,
                                title,
                                "It's time for your reminder!",
                                time,
                                customAudioPath: reminder['customAudioPath']?.toString(),
                              );
                            }
                          }
                        } else {
                          await Alarm.stop(reminderId.hashCode);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
  Widget _buildPremiumFestivalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ui.upcoming_festivals'.tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Text(
                'सभी देखें >',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _upcomingFestivalsFuture,
          builder: (context, snapshot) {
            final isSkeleton = _dataState == DataState.skeleton || 
                snapshot.connectionState == ConnectionState.waiting || 
                snapshot.hasError || 
                !snapshot.hasData;
            
            if (isSkeleton) {
              return SizedBox(
                height: 100, // Extra padding space for the 80 height box
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) => const FastsAndFestivalsSkeleton(),
                ),
              );
            }
            final festivals = snapshot.data ?? [];
            if (festivals.isEmpty) {
              return const Center(child: Text('No upcoming festivals', style: TextStyle(color: Colors.white54)));
            }
            return CarouselSlider.builder(
              itemCount: festivals.length,
              options: CarouselOptions(
                height: 220,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                viewportFraction: 0.6,
                padEnds: false,
              ),
              itemBuilder: (context, index, realIndex) {
                final festival = festivals[index];
                final urgencyText = _calculateUrgency(festival['date'].toString());
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _premiumFestivalCard(
                    title: getLocalizedText(festival['title'], context.locale.languageCode).isEmpty ? 'Unknown' : getLocalizedText(festival['title'], context.locale.languageCode),
                    date: festival['date']?.toString() ?? '',
                    icon: Icons.brightness_7_rounded,
                    urgencyText: urgencyText,
                    pujaVidhiContent: getLocalizedText(festival['puja_vidhi_content'], context.locale.languageCode),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
  Widget _premiumFestivalCard({
    required String title,
    required String date,
    required IconData icon,
    required String urgencyText,
    String? pujaVidhiContent,
  }) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE7D8B1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.brightness_7_rounded,
                        color: Color(0xFFC9A227),
                        size: 28,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF1A1A1A) : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Noto Sans Devanagari',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF6B6258) : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showPujaVidhiBottomSheet(title, pujaVidhiContent);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04), // Translucent background
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ui.puja_vidhi'.tr(),
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Noto Sans Devanagari',
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFD4AF37),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (urgencyText.isNotEmpty)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE7D8B1)),
                ),
                child: Text(
                  urgencyText,
                  style: const TextStyle(
                    color: Color(0xFFC9A227),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Noto Sans Devanagari',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildBottomNavigationBar() {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light ? Colors.white.withOpacity(0.75) : const Color(0xFF0D0D0D).withOpacity(0.9),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFE7D8B1).withOpacity(0.8),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home, 'nav.home'.tr()),
                  _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month, 'nav.panchang'.tr()),
                  _buildNavItem(2, Icons.storefront_outlined, Icons.storefront, 'nav.shop'.tr()),
                  _buildNavItem(3, Icons.person_outline, Icons.person, 'nav.profile'.tr()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  key: ValueKey<bool>(isSelected),
                  color: isSelected ? const Color(0xFFC9A227) : const Color(0xFF6B6258).withOpacity(0.7),
                  size: isSelected ? 26 : 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFC9A227) : const Color(0xFF6B6258).withOpacity(0.7),
                  fontSize: isSelected ? 11 : 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class SliderAngledLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFFC5A880)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    Path path = Path();
    path.moveTo(size.width * 0.60, 0);
    path.lineTo(size.width * 0.50, size.height);
    Paint glowPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.5)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _BreathingReminderIcon extends StatefulWidget {
  final VoidCallback onTap;
  const _BreathingReminderIcon({required this.onTap});

  @override
  State<_BreathingReminderIcon> createState() => _BreathingReminderIconState();
}

class _BreathingReminderIconState extends State<_BreathingReminderIcon> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isExpanded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1.0, end: _isExpanded ? 1.15 : 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutSine,
          onEnd: () {
            if (mounted) setState(() => _isExpanded = !_isExpanded);
          },
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: const Icon(
                Icons.notification_add_rounded,
                color: Color(0xFFD4AF37),
                size: 56.0,
              ),
            );
          },
        ),
      ),
    );
  }
}
class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure Black
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Glass effect ideally, but simple for dummy
        elevation: 0,
        title: Text(
          '$title Screen',
          style: const TextStyle(
            color: Color(0xFFD4AF37), // Refined Gold
            fontFamily: 'Serif',
            fontWeight: FontWeight.w400,
            letterSpacing: 2.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Center(
        child: Text(
          '$title Content Area',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
            fontFamily: 'Serif',
          ),
        ),
      ),
    );
  }
}
