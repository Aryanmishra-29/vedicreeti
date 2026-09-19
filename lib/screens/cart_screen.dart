import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../cart_service.dart';
import '../auth_bottom_sheet.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'checkout_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/localization_helper.dart';
import '../widgets/auto_scroll_text.dart';

class CartScreen extends StatefulWidget {
  final CartItem? directPurchaseItem;
  const CartScreen({super.key, this.directPurchaseItem});
  @override
  State<CartScreen> createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;
  bool _isProcessingPayment = false;
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful! Order ID: ${response.orderId}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    if (widget.directPurchaseItem == null) {
      CartService.instance.clearCart();
    }
    Navigator.pop(context);
  }
  List<CartItem> get _itemsToCheckout {
    if (widget.directPurchaseItem != null) {
      return [widget.directPurchaseItem!];
    }
    return CartService.instance.items;
  }
  double get _checkoutTotal {
    if (widget.directPurchaseItem != null) {
      return widget.directPurchaseItem!.price * widget.directPurchaseItem!.quantity;
    }
    return CartService.instance.totalPrice;
  }
  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  Future<void> _startCheckout() async {
    if (kDebugMode) print('Checkout pressed');
    final session = Supabase.instance.client.auth.currentSession;
    if (kDebugMode) print('DEBUG AUTH SESSION: $session');
    if (session == null) {
      if (kDebugMode) print('ABORTING: User is not logged in.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to complete your purchase.'),
          backgroundColor: Colors.orange,
        ),
      );
      AuthBottomSheet.show(context);
      return;
    }
    if (_itemsToCheckout.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }
    final cartTotal = _checkoutTotal;
    if (cartTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart total must be greater than 0')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          items: _itemsToCheckout,
          totalAmount: cartTotal,
          isDirectPurchase: widget.directPurchaseItem != null,
        ),
      ),
    );
  }
  Future<void> _processPayment(Session session, double cartTotal, Map<String, dynamic> deliveryDetails) async {
    setState(() => _isProcessingPayment = true);
    try {
      if (kDebugMode) print('Sending payment payload: Amount = $cartTotal');
      final payloadItems = _itemsToCheckout.map((item) => {
        'product_id': item.id,
        'quantity': item.quantity
      }).toList();
      final response = await Supabase.instance.client.functions.invoke(
        'create-secure-checkout',
        body: {
          'user_id': session.user.id,
          'items': payloadItems,
          'delivery_address': deliveryDetails
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      final data = response.data;
      if (data == null || data['order_id'] == null) {
        throw Exception('Failed to generate Order ID');
      }
      final String orderId = data['order_id'];
      final user = Supabase.instance.client.auth.currentUser;
      final email = user?.email ?? 'customer@example.com';
      final phone = deliveryDetails['phone'] ?? user?.phone ?? '9999999999';
      var options = {
        'key': dotenv.env['RAZORPAY_TEST_KEY'] ?? '',
        'amount': (data['amount'] * 100).toInt(), // in paise
        'name': 'VedicReeti',
        'order_id': orderId,
        'description': 'Cart Checkout',
        'prefill': {
          'contact': phone,
          'email': email,
        },
        'theme': {
          'color': '#FF5722' // Deep Orange theme color
        }
      };
      if (kIsWeb) {
        setState(() => _isProcessingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Web checkout not implemented yet. Please use the mobile app.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        _razorpay.open(options);
      }
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      if (kDebugMode) print('PAYMENT INITIATION ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not initiate payment. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.directPurchaseItem != null ? 'Direct Checkout' : 'Your Cart',
          style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: widget.directPurchaseItem != null
          ? _buildCartView()
          : ListenableBuilder(
              listenable: CartService.instance,
              builder: (context, _) => _buildCartView(),
            ),
    );
  }
  Widget _buildCartView() {
    final items = _itemsToCheckout;
    if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade500),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Continue Shopping', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                          ),
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: item.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                                        )
                                      : Icon(Icons.spa_rounded, color: Theme.of(context).iconTheme.color),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AutoScrollText(
                                        getLocalizedText(item.name, context.locale.languageCode),
                                        style: GoogleFonts.playfairDisplay(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '₹${item.price.toStringAsFixed(0)}',
                                        style: GoogleFonts.playfairDisplay(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFF97316),
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    if (widget.directPurchaseItem == null)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => CartService.instance.removeItem(item.id),
                                      ),
                                    if (widget.directPurchaseItem == null)
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () => CartService.instance.updateQuantity(item.id, item.quantity - 1),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Icon(Icons.remove, size: 16, color: Theme.of(context).iconTheme.color),
                                              ),
                                            ),
                                            Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                                            InkWell(
                                              onTap: () => CartService.instance.updateQuantity(item.id, item.quantity + 1),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Icon(Icons.add, size: 16, color: Theme.of(context).iconTheme.color),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Qty: ${item.quantity}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${_checkoutTotal.toStringAsFixed(0)}',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _isProcessingPayment ? null : _startCheckout,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8C00), Color(0xFFE65C00)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8C00).withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _isProcessingPayment
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Proceed to Checkout',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_isProcessingPayment)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),
                ),
            ],
          );
  }
}
