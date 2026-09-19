import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF151515) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFD4AF37).withOpacity(0.3) : const Color(0xFFE7D8B1),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Shimmer.fromColors(
              baseColor: const Color(0xFF1A1A1A),
              highlightColor: const Color(0xFF2A2211),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Shimmer.fromColors(
                  baseColor: const Color(0xFF1A1A1A),
                  highlightColor: const Color(0xFF2A2211),
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: const Color(0xFF1A1A1A),
                  highlightColor: const Color(0xFF2A2211),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 18,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Shimmer.fromColors(
                  baseColor: const Color(0xFF1A1A1A),
                  highlightColor: const Color(0xFF2A2211),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                OverflowBar(
                  spacing: 8.0,
                  overflowSpacing: 8.0,
                  children: [
                    Shimmer.fromColors(
                      baseColor: const Color(0xFF1A1A1A),
                      highlightColor: const Color(0xFF2A2211),
                      child: SizedBox(
                        width: 48,
                        height: 36, // Approximate height of OutlinedButton
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: const Color(0xFF1A1A1A),
                      highlightColor: const Color(0xFF2A2211),
                      child: SizedBox(
                        width: 80, // Approximate width of Buy Now button
                        height: 36,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
