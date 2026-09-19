import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class SpiritualProfileSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const SpiritualProfileSheet({super.key, required this.onSaved});
  static void show(BuildContext context, VoidCallback onSaved) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SpiritualProfileSheet(onSaved: onSaved),
    );
  }
  @override
  State<SpiritualProfileSheet> createState() => _SpiritualProfileSheetState();
}
class _SpiritualProfileSheetState extends State<SpiritualProfileSheet> {
  String? _selectedGotra;
  String? _selectedRashi;
  bool _isSaving = false;
  final List<String> _gotras = [
    'Kashyap', 'Bharadwaj', 'Vashistha', 'Agastya', 'Garg',
    'Kaushik', 'Gautam', 'Shandilya', 'Atri', 'Bhrigu', 'Other'
  ];
  final List<String> _rashis = [
    'Aries (Mesh)', 'Taurus (Vrishabha)', 'Gemini (Mithun)', 'Cancer (Karka)',
    'Leo (Simha)', 'Virgo (Kanya)', 'Libra (Tula)', 'Scorpio (Vrishchika)',
    'Sagittarius (Dhanu)', 'Capricorn (Makar)', 'Aquarius (Kumbha)', 'Pisces (Meen)'
  ];
  final Map<String, String> _rashiSymbols = {
    'Aries (Mesh)': '♈',
    'Taurus (Vrishabha)': '♉',
    'Gemini (Mithun)': '♊',
    'Cancer (Karka)': '♋',
    'Leo (Simha)': '♌',
    'Virgo (Kanya)': '♍',
    'Libra (Tula)': '♎',
    'Scorpio (Vrishchika)': '♏',
    'Sagittarius (Dhanu)': '♐',
    'Capricorn (Makar)': '♑',
    'Aquarius (Kumbha)': '♒',
    'Pisces (Meen)': '♓'
  };
  Future<void> _saveProfile() async {
    if (_selectedGotra == null || _selectedRashi == null) return;
    setState(() {
      _isSaving = true;
    });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final currentMeta = Map<String, dynamic>.from(user.userMetadata ?? {});
        final int currentKarma = (currentMeta['karma_points'] as num?)?.toInt() ?? 0;
        currentMeta['gotra'] = _selectedGotra;
        currentMeta['rashi'] = _selectedRashi;
        currentMeta['karma_points'] = currentKarma + 50; // Award 50 karma
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: currentMeta),
        );
        try {
          await Supabase.instance.client.from('user_completed_tasks').insert({
            'user_id': user.id,
            'task_id': 'task_profile',
            'completed_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {
          // Ignore if already completed
        }
        HapticFeedback.heavyImpact();
        if (mounted) {
          Navigator.pop(context);
          widget.onSaved();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ +50 Karma Points Awarded!'),
              backgroundColor: Color(0xFFC9922A),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black.withOpacity(0.65) : Colors.white.withOpacity(0.85),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Icon(Icons.stars_rounded, color: Color(0xFFD4AF37), size: 48),
                const SizedBox(height: 12),
                Text(
                  'Spiritual Identity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair Display',
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete your profile to receive personalized puja recommendations and unlock +50 Karma Points.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                _buildDropdown(
                  icon: Icons.history_edu_rounded,
                  label: 'Your Gotra',
                  value: _selectedGotra,
                  items: _gotras,
                  onChanged: (val) {
                    setState(() {
                      _selectedGotra = val;
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  icon: Icons.nightlight_round,
                  label: 'Your Rashi (Zodiac)',
                  value: _selectedRashi,
                  items: _rashis,
                  onChanged: (val) {
                    setState(() {
                      _selectedRashi = val;
                    });
                  },
                  isDarkMode: isDarkMode,
                  symbolMap: _rashiSymbols,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_selectedGotra != null && _selectedRashi != null && !_isSaving)
                        ? _saveProfile
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFD4AF37).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Save & Claim +50 Karma',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDropdown({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDarkMode,
    Map<String, String>? symbolMap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.black12,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              if (value != null && symbolMap != null && symbolMap[value] != null)
                Text(
                  symbolMap[value]!,
                  style: const TextStyle(fontSize: 20, color: Color(0xFFD4AF37), height: 1.0),
                )
              else
                Icon(icon, color: const Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDarkMode ? Colors.white54 : Colors.black54,
          ),
          isExpanded: true,
          dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: items.map((String item) {
            final symbol = symbolMap?[item];
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (symbol != null)
                    Text(
                      symbol,
                      style: const TextStyle(fontSize: 20, color: Color(0xFFD4AF37), height: 1.0),
                    )
                  else
                    Icon(icon, color: const Color(0xFFD4AF37), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    item,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
