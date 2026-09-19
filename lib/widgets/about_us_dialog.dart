import 'dart:ui';
import 'package:flutter/material.dart';
class AboutUsDialog extends StatelessWidget {
  const AboutUsDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0D0D0D) : const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                width: 1,
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'About VedicReeti',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Serif',
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bringing the divine essence of Sanatan Dharma to your fingertips. Experience premium and authentic Vedic rituals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6258),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Founded & Engineered by',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF888888) : const Color(0xFF8C847A),
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aryan Ajay Kumar Mishra',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE5E5E5) : const Color(0xFF1A1A1A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 14)),
                ),
                const SizedBox(height: 32),
                Text(
                  'v1.0.0 (Build 1)',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF666666) : const Color(0xFF999999),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2026 VedicReeti. All rights reserved.',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF555555) : const Color(0xFFAAAAAA),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
