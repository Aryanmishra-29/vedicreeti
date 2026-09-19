import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
class RealtimeBufferService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;
  StreamSubscription? _bufferSub;
  final _dataController = BehaviorSubject<List<Map<String, dynamic>>>();
  Stream<List<Map<String, dynamic>>> get dataStream => _dataController.stream;
  final _rawUpdateController = PublishSubject<Map<String, dynamic>>();
  void initializeStream(String tableName) {
    _bufferSub = _rawUpdateController
        .bufferTime(const Duration(milliseconds: 500))
        .where((batch) => batch.isNotEmpty)
        .listen((batchedUpdates) {
          _processBatchedUpdates(batchedUpdates);
        });
    _channel = _client.channel('public:$tableName');
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: tableName,
          callback: (payload) {
            _rawUpdateController.add(payload.newRecord);
          },
        )
        .subscribe();
  }
  void _processBatchedUpdates(List<Map<String, dynamic>> batch) {
    final currentList = List<Map<String, dynamic>>.from(_dataController.valueOrNull ?? []);
    currentList.insertAll(0, batch);
    _dataController.add(currentList);
  }
  void dispose() {
    _bufferSub?.cancel();
    _channel?.unsubscribe();
    _rawUpdateController.close();
    _dataController.close();
  }
}
