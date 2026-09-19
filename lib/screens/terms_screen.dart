import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white70 : const Color(0xFF2A241D);
    final Color titleColor = isDark ? const Color(0xFFD4AF37) : const Color(0xFFC9A227);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.playfairDisplay(
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Text(
          '''1. Introduction
Welcome to VedicReeti. By accessing our app, you agree to these terms.
2. Services
We provide accurate Panchang, Puja Booking, and E-commerce services.
3. User Conduct
Users must not misuse our services or provide false information.
4. Payments
All transactions are secure and encrypted.
5. Modifications
We reserve the right to modify these terms at any time.
(Placeholder for comprehensive legal terms)''',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
