import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'cache_service.dart';
import 'widgets/grid_product_skeleton_card.dart';
import 'widgets/offline_retry_banner.dart';
import 'cart_service.dart';
import 'screens/cart_screen.dart';
import 'widgets/product_card.dart';
import 'widgets/heart_button.dart';
import 'widgets/product_skeleton_grid.dart';
import 'widgets/product_card_skeleton.dart';
import 'widgets/connection_lost_screen.dart';

enum DataState { loaded, skeleton, offlineError }

class RetailScreen extends StatefulWidget {
  const RetailScreen({super.key});
  @override
  State<RetailScreen> createState() => _RetailScreenState();
}
class _RetailScreenState extends State<RetailScreen> {
  late final Stream<List<Map<String, dynamic>>> _productsStream;
  DataState _dataState = DataState.loaded;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _offlineTimer;

  @override
  void initState() {
    super.initState();
    _productsStream = Supabase.instance.client
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('created_at');
    _checkConnectivityAndListen();
  }

  @override
  void dispose() {
    _offlineTimer?.cancel();
    _connectivitySubscription?.cancel();
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
            _dataState = DataState.loaded;
          });
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ui.spiritual_store'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D),
            fontFamily: 'Serif'
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D)),
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: _dataState == DataState.offlineError
          ? _buildOfflinePremiumWidget()
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _productsStream,
                    builder: (context, snapshot) {
                      final bool isSkeleton = _dataState == DataState.skeleton || 
                          (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData);
                      final products = snapshot.data ?? [];
                      
                      if (!isSkeleton && snapshot.hasError) {
                        debugPrint('Store fetch error: ${snapshot.error}');
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
                            } else {
                              setState(() {
                                _dataState = DataState.loaded;
                              });
                            }
                          },
                        );
                      }
                      
                      if (!isSkeleton && products.isEmpty) {
                        return const Center(child: Text('No products available.', style: TextStyle(color: Colors.grey)));
                      }
                      
                      if (!isSkeleton) {
                        CacheService.saveCache('retail_products', products);
                      }

                      final int itemCount = isSkeleton ? 6 : products.length;

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: MasonryGridView.count(
                          key: ValueKey<int>(isSkeleton ? -1 : products.length),
                          padding: const EdgeInsets.all(20),
                          cacheExtent: 500.0,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (isSkeleton) {
                              return const ProductCardSkeleton();
                            }
                            
                            final product = products[index];
                            final productId = product['id']?.toString() ?? '';
                            return ProductCard(
                              product: product,
                              topTrailingAction: productId.isNotEmpty ? HeartButton(productId: productId) : null,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: ListenableBuilder(
        listenable: CartService.instance,
        builder: (context, child) {
          final itemCount = CartService.instance.itemCount;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                backgroundColor: const Color(0xFFC9A227),
                elevation: 8,
                shape: const CircleBorder(),
                child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 26),
              ),
              if (itemCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      child: Text(
                        '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
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
}
