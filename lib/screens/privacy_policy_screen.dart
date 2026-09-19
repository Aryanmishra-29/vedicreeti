import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white70 : const Color(0xFF2A241D);
    final Color titleColor = isDark ? const Color(0xFFD4AF37) : const Color(0xFFC9A227);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
          '''1. Information Collection
We collect minimal data required to provide accurate Panchang services and secure E-commerce checkout.
2. Data Usage
Your data is used strictly to enhance your experience within the VedicReeti ecosystem.
3. Third-Party Sharing
We do not sell your personal data to third parties.
4. Data Security
All communications and data storage use industry-standard encryption.
5. Your Rights
You can request account deletion at any time from the Profile section.
(Placeholder for comprehensive privacy policy)''',
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
