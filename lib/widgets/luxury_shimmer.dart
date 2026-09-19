import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class LuxuryShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;
  const LuxuryShimmer({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 12.0,
    this.shape = BoxShape.rectangle,
  });
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFD4AF37),
      highlightColor: const Color(0xFFF9E79F),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
class LuxuryShimmerLogo extends StatelessWidget {
  const LuxuryShimmerLogo({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFD4AF37).withOpacity(0.4),
      highlightColor: const Color(0xFFD4AF37),
      child: Image.asset(
        'assets/images/logo_dark.png',
        height: 60,
        fit: BoxFit.contain,
      ),
    );
  }
}
