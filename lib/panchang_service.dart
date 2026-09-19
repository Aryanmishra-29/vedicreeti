import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'cache_service.dart';
import 'services/notification_service.dart';
class PanchangService {
  static final PanchangService _instance = PanchangService._internal();
  factory PanchangService() => _instance;
  PanchangService._internal();
  final Map<String, Future<Map<String, dynamic>>> _inflightRequests = {};
  Future<Map<String, dynamic>> fetchPanchangData(DateTime date, {double? lat, double? lon}) async {
    final String cacheKey = _cacheKeyForDate(date);
    final cached = await CacheService.loadCache(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      developer.log(
        'Hive cache HIT for $cacheKey – returning cached data & syncing in background',
        name: 'PanchangService',
      );
      _syncFromApi(date, lat, lon).catchError((e) {
        developer.log('Background sync failed for $cacheKey',
            name: 'PanchangService', error: e);
      });
      return Map<String, dynamic>.from(cached.first);
    }
    developer.log(
      'Hive cache MISS for $cacheKey – performing blocking network fetch',
      name: 'PanchangService',
    );
    return _syncFromApi(date, lat, lon);
  }
  String _cacheKeyForDate(DateTime date) {
    return 'panchang_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
  }
  Future<Map<String, dynamic>> _syncFromApi(DateTime date, double? lat, double? lon) {
    final String cacheKey = _cacheKeyForDate(date);
    final String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (_inflightRequests.containsKey(cacheKey)) {
      return _inflightRequests[cacheKey]!;
    }
    final future = _fetchFromApi(formattedDate, lat, lon).then((data) async {
      await CacheService.saveCache(cacheKey, [data]);
      developer.log('Persisted panchang data to Hive for $cacheKey',
          name: 'PanchangService');
      return data;
    }).whenComplete(() {
      _inflightRequests.remove(cacheKey);
    });
    _inflightRequests[cacheKey] = future;
    return future;
  }
  Future<Map<String, dynamic>> _fetchFromApi(String formattedDate, double? lat, double? lon) async {
    try {
      final Map<String, String> queryParams = {
        'date': formattedDate,
        'lat': lat?.toString() ?? '19.18',
        'lon': lon?.toString() ?? '73.04',
      };
      final uri = Uri.parse(
        'https://panchang-api-eight.vercel.app/api/v1/panchang',
      ).replace(queryParameters: queryParams);
      final String apiKey = 'ARYANMISHRA@29';
      final response = await http
          .get(
            uri,
            headers: {
              'x-api-key': apiKey,
              'Authorization': 'Bearer $apiKey',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final decoded = json.decode(decodedResponse);
        if (decoded is String) {
          throw Exception('API Server Message: $decoded');
        }
        final Map<String, dynamic> apiData = decoded['data'] ?? {};
        String formatToIST(String? isoString) {
          if (isoString == null || isoString == 'N/A' || isoString.isEmpty) return 'N/A';
          try {
            DateTime parsed = DateTime.parse(isoString);
            DateTime istTime = parsed.toUtc().add(const Duration(hours: 5, minutes: 30));
            return DateFormat('hh:mm a').format(istTime);
          } catch (e) {
            return 'N/A';
          }
        }
        String formatMuhurat(Map<String, dynamic>? muhuratNode) {
          if (muhuratNode == null) return 'N/A';
          final start = formatToIST(muhuratNode['start']);
          final end = formatToIST(muhuratNode['end']);
          if (start == 'N/A' || end == 'N/A') return 'N/A';
          return "$start - $end";
        }
        String tithi = 'N/A';
        if (apiData['tithi'] != null) {
          if (apiData['tithi'] is Map) {
            final tithiMap = apiData['tithi'] as Map<String, dynamic>;
            if (tithiMap.containsKey('details') && tithiMap['details'] is Map) {
              tithi = tithiMap['details']['tithi_name']?.toString() ?? 'N/A';
            } else if (tithiMap.containsKey('name')) {
              tithi = tithiMap['name']?.toString() ?? 'N/A';
            }
          } else {
            tithi = apiData['tithi'].toString();
          }
        }
        String formattedTithi = tithi
            .replaceAll('(S)', '(शुक्ल पक्ष)')
            .replaceAll('(K)', '(कृष्ण पक्ष)');
        String nakshatra = 'N/A';
        if (apiData['nakshatra'] != null) {
          if (apiData['nakshatra'] is Map) {
            final nakshMap = apiData['nakshatra'] as Map<String, dynamic>;
            if (nakshMap.containsKey('details') && nakshMap['details'] is Map) {
              nakshatra = nakshMap['details']['nakshatra_name']?.toString() ?? 'N/A';
            } else if (nakshMap.containsKey('name')) {
              nakshatra = nakshMap['name']?.toString() ?? 'N/A';
            }
          } else {
            nakshatra = apiData['nakshatra'].toString();
          }
        }
        if (apiData['festivals'] != null && apiData['festivals'] is List) {
          NotificationService().autoScheduleFestivalReminders(apiData['festivals'] as List<dynamic>);
        }
        return {
          'tithi': formattedTithi,
          'nakshatra': nakshatra,
          'sun_rise': formatToIST(apiData['sunDetails']?['sunrise']),
          'sun_set': formatToIST(apiData['sunDetails']?['sunset']),
          'abhijit_muhurta': formatMuhurat(apiData['muhurat']?['abhijit']),
          'rahu_kaal': formatMuhurat(apiData['muhurat']?['rahuKaal']),
          'amrit_kaal': formatMuhurat(apiData['muhurat']?['amritKaal']),
        };
      } else {
        throw Exception('Failed to load panchang data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API unavailable, offline, or missing API key.');
    }
  }
}
