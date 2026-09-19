import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class BookingSuccessScreen extends StatelessWidget {
  final String panditName;
  final String panditContact;
  final String specialization;
  const BookingSuccessScreen({
    super.key,
    required this.panditName,
    required this.panditContact,
    required this.specialization,
  });
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDark ? const Color(0xFFFDFBF7) : const Color(0xFF2C2C2C);
    final Color mutedTextColor = isDark ? Colors.white70 : Colors.black54;
    final Color cardBg = isDark ? const Color(0xFF1A1A1D) : Theme.of(context).colorScheme.surface;
    final Color goldColor = isDark ? const Color(0xFFC9A227) : const Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: goldColor,
                size: 100,
              ),
              const SizedBox(height: 32),
              Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your divine service has been successfully scheduled. Your assigned Pandit details are below.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: mutedTextColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: goldColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Pandit',
                      style: GoogleFonts.montserrat(
                        color: goldColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      panditName,
                      style: GoogleFonts.playfairDisplay(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.phone_rounded, color: mutedTextColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          panditContact,
                          style: GoogleFonts.montserrat(
                            color: mutedTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.star_border_rounded, color: mutedTextColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            specialization,
                            style: GoogleFonts.montserrat(
                              color: mutedTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.montserrat(
                    color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
