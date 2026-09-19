import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});
  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}
class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Locale? selectedLocale;
  Future<void> _saveLanguage() async {
    if (selectedLocale == null) return;
    await context.setLocale(selectedLocale!);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeUser', false);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }
  String _getSaveText(Locale locale) {
    switch (locale.languageCode) {
      case 'hi': return 'सहेजें';
      case 'mr': return 'जतन करा';
      case 'gu': return 'સાચવો';
      case 'bn': return 'সংরক্ষণ করুন';
      case 'ta': return 'சேமி';
      case 'te': return 'సేవ్ చేయండి';
      case 'kn': return 'ಉಳಿಸಿ';
      case 'ml': return 'സേവ് ചെയ്യുക';
      case 'pa': return 'ਸੇਵ ਕਰੋ';
      default: return 'Save & Apply';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Choose Your Language',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'अपनी भाषा चुनें / आपली भाषा निवडा',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _buildLanguageOption(
                      title: 'English',
                      subtitle: 'English',
                      nativeChar: 'A',
                      locale: const Locale('en'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      title: 'हिन्दी',
                      subtitle: 'Hindi',
                      nativeChar: 'अ',
                      locale: const Locale('hi'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      title: 'मराठी',
                      subtitle: 'Marathi',
                      nativeChar: 'म',
                      locale: const Locale('mr'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      title: 'ગુજરાતી',
                      subtitle: 'Gujarati',
                      nativeChar: 'ગુ',
                      locale: const Locale('gu'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      title: 'বাংলা',
                      subtitle: 'Bengali',
                      nativeChar: 'অ',
                      locale: const Locale('bn'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      title: 'தமிழ்',
                      subtitle: 'Tamil',
                      nativeChar: 'த',
                      locale: const Locale('ta'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      title: 'తెలుగు',
                      subtitle: 'Telugu',
                      nativeChar: 'తె',
                      locale: const Locale('te'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      title: 'ಕನ್ನಡ',
                      subtitle: 'Kannada',
                      nativeChar: 'ಕ',
                      locale: const Locale('kn'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      title: 'മലയാളം',
                      subtitle: 'Malayalam',
                      nativeChar: 'മ',
                      locale: const Locale('ml'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageOption(
                      title: 'ਪੰਜਾਬੀ',
                      subtitle: 'Punjabi',
                      nativeChar: 'ਪ',
                      locale: const Locale('pa'),
                    ),
                  ],
                ),
              ),
              if (selectedLocale != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveLanguage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _getSaveText(selectedLocale!),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
              ]
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLanguageOption({required String title, required String subtitle, required String nativeChar, required Locale locale}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedLocale == locale;
    return InkWell(
      onTap: () {
        setState(() {
          selectedLocale = locale;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: isSelected ? 2.5 : 1.5,
          ),
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).cardColor,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              ),
              alignment: Alignment.center,
              child: Text(
                nativeChar,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
