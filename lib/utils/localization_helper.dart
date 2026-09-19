import 'dart:convert';

String getLocalizedText(dynamic jsonField, String currentLocale) {
  if (jsonField == null) return '';
  Map<String, dynamic> dataMap = {};

  if (jsonField is String) {
    try { dataMap = jsonDecode(jsonField); } catch (e) { return jsonField; }
  } else if (jsonField is Map) {
    dataMap = Map<String, dynamic>.from(jsonField);
  }

  if (dataMap.containsKey(currentLocale) && dataMap[currentLocale] != null && dataMap[currentLocale].toString().isNotEmpty) {
    return dataMap[currentLocale].toString();
  } else if (dataMap.containsKey('hi') && dataMap['hi'] != null) {
    return dataMap['hi'].toString(); // Fallback to Hindi
  } else if (dataMap.containsKey('en') && dataMap['en'] != null) {
    return dataMap['en'].toString(); // Fallback to English
  }
  return 'Title Missing';
}
