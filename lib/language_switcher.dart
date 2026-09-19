import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale.languageCode;
    return PopupMenuButton<Locale>(
      onSelected: (Locale newLocale) async {
        await context.setLocale(newLocale);
      },
      tooltip: 'Change Language',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      position: PopupMenuPosition.under,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.deepOrange, size: 20),
            const SizedBox(width: 6),
            Text(
              currentLocale == 'hi' ? 'हिंदी' : currentLocale == 'mr' ? 'मराठी' : 'English',
              style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, color: Colors.deepOrange, size: 20),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: _buildMenuItem('English', currentLocale == 'en'),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('hi'),
          child: _buildMenuItem('हिंदी', currentLocale == 'hi'),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('mr'),
          child: _buildMenuItem('मराठी', currentLocale == 'mr'),
        ),
      ],
    );
  }
  Widget _buildMenuItem(String title, bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepOrange : Colors.black87,
          ),
        ),
        if (isSelected) const Icon(Icons.check_circle, color: Colors.deepOrange, size: 20),
      ],
    );
  }
}
