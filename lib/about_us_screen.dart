import 'package:flutter/material.dart';
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFDFBF7);
    final textColor = isDarkMode ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A);
    final accentColor = isDarkMode ? const Color(0xFFD4AF37) : const Color(0xFFAA7C11);
    final subtitleColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 2,
              color: accentColor,
              margin: const EdgeInsets.only(bottom: 24),
            ),
            Text(
              'Our Heritage',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                fontFamily: 'Playfair Display',
                color: textColor,
                letterSpacing: 1.2,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "At Vedicreeti, we bridge the gap between ancient spiritual heritage and the modern seeker. Born from a profound respect for Vedic traditions, our mission is to provide 100% authentic, certified spiritual artifacts. From rare, sanctified Rudrakshas to premium divine elements, every item is meticulously sourced, verified, and handled with the utmost purity. We don't just deliver products; we bring divine energy, peace, and timeless tradition directly to your doorstep.",
              style: TextStyle(
                fontSize: 15,
                height: 1.8,
                color: subtitleColor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
