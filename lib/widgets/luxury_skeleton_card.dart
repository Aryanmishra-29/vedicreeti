import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LuxurySkeletonCard extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsetsGeometry margin;

  const LuxurySkeletonCard({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 16.0,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: const Color(0xFFD4AF37).withOpacity(0.1),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.black, // Required for shimmer to work
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
