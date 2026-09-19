import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../cart_service.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/localization_helper.dart';
import 'order_success_screen.dart';
class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  final double totalAmount;
  final bool isDirectPurchase;
  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalAmount,
    this.isDirectPurchase = false,
  });
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}
class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinController = TextEditingController();
  List<Map<String, dynamic>> _savedAddresses = [];
  int _selectedAddressIndex = -1;
  bool _isLoadingAddresses = true;
  String _paymentMethod = 'COD'; // 'COD' or 'ONLINE'
  late Razorpay _razorpay;
  bool _isProcessing = false;
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchSavedAddresses();
  }
  Future<void> _fetchSavedAddresses() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      setState(() => _isLoadingAddresses = false);
      return;
    }
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select('delivery_address')
          .eq('user_id', session.user.id)
          .order('created_at', ascending: false)
          .limit(10);
      final List<Map<String, dynamic>> addresses = [];
      final Set<String> seen = {};
      for (var row in response) {
        if (row['delivery_address'] != null) {
          final addr = row['delivery_address'] as Map<String, dynamic>;
          final key = '${addr['name']}-${addr['phone']}-${addr['address']}-${addr['pincode']}';
          if (!seen.contains(key)) {
            seen.add(key);
            addresses.add(addr);
          }
        }
      }
      setState(() {
        _savedAddresses = addresses;
        _isLoadingAddresses = false;
      });
    } catch (e) {
      if (kDebugMode) print('Error fetching saved addresses: $e');
      setState(() => _isLoadingAddresses = false);
    }
  }
  void _onAddressSelected(int index) {
    setState(() {
      _selectedAddressIndex = index;
    });
    final addr = _savedAddresses[index];
    _nameController.text = addr['name']?.toString() ?? '';
    _phoneController.text = addr['phone']?.toString() ?? '';
    _addressController.text = addr['address']?.toString() ?? '';
    _pinController.text = addr['pincode']?.toString() ?? '';
  }
  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pinController.dispose();
    super.dispose();
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    _onOrderComplete(response.orderId ?? 'SUCCESS');
  }
  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
  }
  void _onOrderComplete(String orderId) {
    if (!widget.isDirectPurchase) {
      CartService.instance.clearCart();
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderSuccessScreen(orderId: orderId)),
    );
  }
  Future<void> _placeOrder() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;
    setState(() => _isProcessing = true);
    try {
      if (kDebugMode) print('DEBUG [CheckoutScreen]: Initiating order placement (Payment Method: $_paymentMethod, Total: ${widget.totalAmount})');
      final payloadItems = widget.items.map((item) => {
        'product_id': item.id,
        'quantity': item.quantity
      }).toList();
      final deliveryDetails = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'pincode': _pinController.text.trim(),
      };
      final response = await Supabase.instance.client.functions.invoke(
        'create-secure-checkout',
        body: {
          'user_id': session.user.id,
          'items': payloadItems,
          'delivery_address': deliveryDetails,
          'payment_method': _paymentMethod,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      final data = response.data;
      if (data == null || data['order_id'] == null) {
        throw Exception('Failed to generate Order ID');
      }
      if (_paymentMethod == 'COD') {
        setState(() => _isProcessing = false);
        _onOrderComplete(data['order_id']);
        return;
      }
      final user = Supabase.instance.client.auth.currentUser;
      final email = user?.email ?? 'customer@example.com';
      var options = {
        'key': dotenv.env['RAZORPAY_TEST_KEY'] ?? '',
        'amount': (data['amount'] * 100).toInt(),
        'name': 'VedicReeti',
        'order_id': data['order_id'],
        'description': 'Cart Checkout',
        'prefill': {
          'contact': _phoneController.text.trim(),
          'email': email,
        },
        'theme': {'color': '#FF5722'}
      };
      if (kIsWeb) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Web checkout not implemented. Use mobile app.')),
        );
      } else {
        _razorpay.open(options);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not place order. Try again.'), backgroundColor: Colors.red),
      );
    }
  }
  InputDecoration _buildInputDecoration(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white54 : Colors.black54,
        fontFamily: 'Montserrat', // or any clean sans-serif
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFF97316).withOpacity(0.5), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
  Widget _buildStepControls(int stepIndex, bool isLast) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (stepIndex == 0) {
                if (_formKey.currentState!.validate()) {
                  setState(() => _currentStep += 1);
                }
              } else if (stepIndex == 1) {
                setState(() => _currentStep += 1);
              } else if (stepIndex == 2) {
                _placeOrder();
              }
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFE65C00)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8C00).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                isLast ? 'Place Your Order' : 'Continue',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        if (stepIndex > 0) ...[
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              setState(() => _currentStep -= 1);
            },
            child: const Text('Back', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ],
    );
  }
  Widget _buildCustomStep({
    required int stepIndex,
    required String title,
    required Widget content,
    required bool isLast,
  }) {
    final bool isActive = _currentStep == stepIndex;
    final bool isPast = _currentStep > stepIndex;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isActive || isPast
                    ? Border.all(color: const Color(0xFFF97316), width: 2)
                    : Border.all(color: isDark ? Colors.white24 : Colors.black12, width: 2),
                color: isActive || isPast
                    ? const Color(0xFFF97316).withOpacity(0.1)
                    : Colors.transparent,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF97316).withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: isPast
                  ? const Icon(Icons.check, size: 18, color: Color(0xFFF97316))
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isActive ? const Color(0xFFF97316) : (isDark ? Colors.white54 : Colors.black54),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive
                    ? Theme.of(context).colorScheme.onSurface
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 15, top: 8, bottom: 8, right: 16),
                width: 2,
                color: isLast ? Colors.transparent : (isDark ? Colors.white12 : Colors.black12),
              ),
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: isActive
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 24.0, right: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              content,
                              const SizedBox(height: 24),
                              _buildStepControls(stepIndex, isLast),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity, height: 24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoadingAddresses)
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
          )
        else if (_savedAddresses.isNotEmpty) ...[
          Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _savedAddresses.length,
              itemBuilder: (context, index) {
                final addr = _savedAddresses[index];
                final isSelected = _selectedAddressIndex == index;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return GestureDetector(
                  onTap: () => _onAddressSelected(index),
                  child: Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFF97316) : (isDark ? Colors.white12 : Colors.black12),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: const Color(0xFFF97316).withOpacity(0.2), blurRadius: 8, spreadRadius: 1)]
                          : [],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                addr['name'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${addr['address'] ?? ''}, PIN: ${addr['pincode'] ?? ''}',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                              addr['phone'] ?? '',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
                            ),
                          ],
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(Icons.check_circle, color: Color(0xFFF97316), size: 18),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Or enter a new address', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
        ],
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Full Name'),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _buildInputDecoration('Phone Number'),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: _buildInputDecoration('Complete Address'),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinController,
                decoration: _buildInputDecoration('PIN Code'),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildPaymentOption({required String title, required String subtitle, required String value}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _paymentMethod,
              activeColor: const Color(0xFFF97316),
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPaymentSelection() {
    return Column(
      children: [
        _buildPaymentOption(
          title: 'Cash on Delivery (COD)',
          subtitle: 'Pay when your order arrives.',
          value: 'COD',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          title: 'UPI / Credit & Debit Cards',
          subtitle: 'Pay securely online via Razorpay.',
          value: 'ONLINE',
        ),
      ],
    );
  }
  Widget _buildOrderReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items (${widget.items.length})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        ...widget.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${getLocalizedText(item.name, context.locale.languageCode)} x${item.quantity}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                  Text('₹${(item.price * item.quantity).toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            )),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Shipping', style: TextStyle(color: Colors.grey)),
            const Text('FREE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment Method', style: TextStyle(color: Colors.grey)),
            Text(_paymentMethod == 'COD' ? 'Cash on Delivery' : 'Online Payment', style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            Text('₹${widget.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF97316))),
          ],
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Checkout', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: _isProcessing
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildCustomStep(
                stepIndex: 0,
                title: 'Delivery Address',
                content: _buildAddressForm(),
                isLast: false,
              ),
              _buildCustomStep(
                stepIndex: 1,
                title: 'Payment Method',
                content: _buildPaymentSelection(),
                isLast: false,
              ),
              _buildCustomStep(
                stepIndex: 2,
                title: 'Order Review',
                content: _buildOrderReview(),
                isLast: true,
              ),
            ],
          ),
    );
  }
}
