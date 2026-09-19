import 'package:supabase_flutter/supabase_flutter.dart';
class DailyShloka {
  final int dayOfYear;
  final String shlokaSanskrut;
  final String meaningHindi;
  final String meaningEnglish;
  final String sourceBook;
  DailyShloka({
    required this.dayOfYear,
    required this.shlokaSanskrut,
    required this.meaningHindi,
    required this.meaningEnglish,
    required this.sourceBook,
  });
  factory DailyShloka.fromJson(Map<String, dynamic> json) {
    return DailyShloka(
      dayOfYear: json['day_of_year'] ?? 1,
      shlokaSanskrut: json['shloka_sanskrut'] ?? '',
      meaningHindi: json['meaning_hindi'] ?? '',
      meaningEnglish: json['meaning_english'] ?? '',
      sourceBook: json['source_book'] ?? '',
    );
  }
  factory DailyShloka.fallback() {
    return DailyShloka(
      dayOfYear: -1,
      shlokaSanskrut: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
      meaningHindi: 'कर्म पर ही तुम्हारा अधिकार है, कर्म के फलों में कभी नहीं... इसलिए कर्म को फल के लिए मत करो और न ही काम न करने में तुम्हारी आसक्ति हो।',
      meaningEnglish: 'You have a right to perform your prescribed duty, but you are not entitled to the fruits of action. Never consider yourself the cause of the results of your activities, and never be attached to not doing your duty.',
      sourceBook: 'Bhagavad Gita 2.47',
    );
  }
}
class ShlokaService {
  static final SupabaseClient _client = Supabase.instance.client;
  static int getCurrentDayOfYear() {
    final now = DateTime.now();
    final dateUtc = DateTime.utc(now.year, now.month, now.day);
    final firstDayOfYear = DateTime.utc(now.year, 1, 1);
    return dateUtc.difference(firstDayOfYear).inDays + 1;
  }
  static Future<DailyShloka> getShlokaOfTheDay() async {
    final int dayOfYear = getCurrentDayOfYear();
    try {
      final dynamic response = await _client
          .from('daily_shlokas')
          .select()
          .eq('day_of_year', dayOfYear)
          .maybeSingle();
      if (response != null) {
        return DailyShloka.fromJson(response as Map<String, dynamic>);
      } else {
        debugPrint('No shloka entry found for day $dayOfYear. Using fallback.');
        return DailyShloka.fallback();
      }
    } catch (e) {
      debugPrint('Network or DB Error fetching daily shloka: $e');
      return DailyShloka.fallback();
    }
  }
  static void debugPrint(String message) {
  }
}
