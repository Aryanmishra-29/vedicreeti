import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
class SecureCheckoutService {
  final SupabaseClient _db = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  Future<String> initiateCheckout(double amount) async {
    final idempotencyKey = _uuid.v4();
    final user = _db.auth.currentUser;
    if (user == null) {
      throw Exception('Authentication Error: Cannot checkout without logging in.');
    }
    final userId = user.id;
    try {
      developer.log('Initiating checkout for user $userId, amount: $amount', name: 'SecureCheckoutService');
      final response = await _db.from('orders').insert({
        'user_id': userId,
        'amount': amount,
        'status': 'pending',
        'idempotency_key': idempotencyKey
      }).select('id').single();
      final String orderId = response['id'].toString();
      developer.log('Order created successfully. OrderId: $orderId', name: 'SecureCheckoutService');
      return orderId;
    } catch (e, stackTrace) {
      developer.log("Transaction aborted locally or DB insert failed. State remains secure.", name: 'SecureCheckoutService', error: e, stackTrace: stackTrace);
      throw Exception('Failed to initiate checkout securely: $e');
    }
  }
  Stream<List<Map<String, dynamic>>> listenForPaymentSuccess(String orderId) {
    developer.log('Listening for payment success on orderId: $orderId', name: 'SecureCheckoutService');
    return _db
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((event) => event.where((order) => order['status'] == 'paid').toList());
  }
  Future<bool> verifyPaymentStatus(String orderId) async {
    try {
      developer.log('Manually verifying payment status for orderId: $orderId', name: 'SecureCheckoutService');
      final response = await _db
          .from('orders')
          .select('status')
          .eq('id', orderId)
          .single();
      return response['status'] == 'paid';
    } catch (e, stackTrace) {
      developer.log('Manual verification failed', name: 'SecureCheckoutService', error: e, stackTrace: stackTrace);
      throw Exception('Network disconnected or verification failed. Please check your internet and retry.');
    }
  }
}
