import 'package:flutter/material.dart';
class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFDFBF7);
    final textColor = isDarkMode ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A);
    final subtitleColor = isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5);
    final bodyColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'The Vedicreeti Experience',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Playfair Display',
                  color: textColor,
                  letterSpacing: 1.0,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                "The Vedicreeti app is your exclusive gateway to the divine. Designed with elegance and simplicity in mind, it offers a seamless, secure, and luxurious shopping experience. Explore our curated catalog of certified spiritual artifacts, read editorial insights into Vedic practices, and manage your spiritual journey with ease. Built for the modern devotee, our platform ensures absolute transparency, secure transactions, and world-class customer support.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.8,
                  color: bodyColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Spacer(),
              Text(
                "Developed by Aryan Mishra",
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Crafted with devotion. © 2026 Vedicreeti.",
                style: TextStyle(
                  fontSize: 11,
                  color: subtitleColor,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
