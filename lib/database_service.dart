Future<List<Map<String, dynamic>>> fetchContent(
  String type,
  String deity,
) async {
  try {
    final response = await _db
        .from('devotional_content')
        .select('*')
        .eq('type', type.toLowerCase())
        .eq('deity', deity.toLowerCase());
    developer.log(
      'Fetched ${response.length} items for $type, $deity',
      name: 'DatabaseService',
    );
    return (response as List).whereType<Map<String, dynamic>>().toList();
  } catch (e) {
    developer.log(
      'Error fetching content: $e',
      name: 'DatabaseService',
      error: e,
    );
    throw Exception('Network or server error: Failed to fetch data from Supabase. Please check connection.');
  }
}
