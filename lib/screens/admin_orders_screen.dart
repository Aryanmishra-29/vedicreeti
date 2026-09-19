import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}
class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _ordersStream;
  final Map<String, Map<String, dynamic>> _profilesCache = {};

  @override
  void initState() {
    super.initState();
    _ordersStream = _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((orders) async {
      final userIdsToFetch = orders
          .map((o) => o['user_id'] as String?)
          .where((id) => id != null && !_profilesCache.containsKey(id))
          .cast<String>()
          .toSet()
          .toList();

      if (userIdsToFetch.isNotEmpty) {
        try {
          final List<dynamic> profiles = await _supabase
              .from('profiles')
              .select('id, email, full_name')
              .inFilter('id', userIdsToFetch);
          for (var p in profiles) {
            _profilesCache[p['id'] as String] = p as Map<String, dynamic>;
          }
        } catch (e) {
          debugPrint('Error fetching profiles: $e');
        }
      }

      return orders.map((o) {
        final updatedOrder = Map<String, dynamic>.from(o);
        final userId = o['user_id'] as String?;
        if (userId != null && _profilesCache.containsKey(userId)) {
          updatedOrder['profiles'] = _profilesCache[userId];
        }
        return updatedOrder;
      }).toList();
    });
  }
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase
          .from('orders')
          .update({'order_status': newStatus})
          .eq('id', orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Manage Orders',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: const [
          SizedBox(width: 48), // Placeholder to keep title centered
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            child = const Center(key: ValueKey('loading'), child: CircularProgressIndicator(color: Colors.deepOrange));
          } else if (snapshot.hasError) {
             child = Center(key: ValueKey('error'), child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else {
             final orders = snapshot.data ?? [];
             if (orders.isEmpty) {
               child = const Center(
                 key: ValueKey('empty'),
                 child: Text(
                   'No orders found',
                   style: TextStyle(fontSize: 18, color: Colors.grey),
                 ),
               );
             } else {
               child = _buildOrdersList(orders);
             }
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
      ),
    );
  }
  Widget _buildOrdersList(List<Map<String, dynamic>> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final profile = order['profiles'] as Map<String, dynamic>?;
        final customerName = profile?['full_name'] ?? 'Unknown Customer';
        final customerEmail = profile?['email'] ?? 'No email provided';
        final totalAmount = order['total_amount'] ?? 0;
        final paymentStatus = order['payment_status'] ?? 'unknown';
        final orderStatus = order['order_status'] ?? 'processing';
        final orderId = order['id'] ?? '';
        final createdAt = order['created_at'] != null
            ? DateTime.parse(order['created_at']).toLocal().toString().split('.')[0]
            : 'Unknown Date';
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Order ID: ${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Text(
                      createdAt,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow(Icons.person_outline, customerName, subtitle: customerEmail),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.currency_rupee,
                  '₹${totalAmount.toStringAsFixed(2)}',
                  subtitle: 'Total Amount',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusBadge(
                        'Payment: ${paymentStatus.toUpperCase()}',
                        _getPaymentStatusColor(paymentStatus),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildOrderStatusDropdown(orderId, orderStatus),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildInfoRow(IconData icon, String title, {String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  Widget _buildOrderStatusDropdown(String orderId, String currentStatus) {
    final statuses = ['processing', 'shipped', 'delivered', 'cancelled'];
    final safeStatus = statuses.contains(currentStatus) ? currentStatus : 'processing';
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeStatus,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
          style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12),
          onChanged: (String? newValue) {
            if (newValue != null && newValue != currentStatus) {
              _updateOrderStatus(orderId, newValue);
            }
          },
          items: statuses.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.toUpperCase()),
            );
          }).toList(),
        ),
      ),
    );
  }
  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'successful':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
