import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class PanchangCardSkeleton extends StatelessWidget {
  const PanchangCardSkeleton({super.key});
  Widget _buildAstroItemSkeleton() {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 14,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade200;
    final highlightColor = isDarkMode ? const Color(0xFF424242) : Colors.grey.shade50;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 14,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 22,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
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
                child: _buildAstroItemSkeleton(),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.5),
              ),
              Expanded(
                child: _buildAstroItemSkeleton(),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.5),
              ),
              Expanded(
                child: _buildAstroItemSkeleton(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
