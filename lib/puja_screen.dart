import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'utils/localization_helper.dart';
class PujaScreen extends StatefulWidget {
  final dynamic puja;
  const PujaScreen({super.key, required this.puja});
  @override
  State<PujaScreen> createState() => _PujaScreenState();
}
class _PujaScreenState extends State<PujaScreen> {
  late Razorpay _razorpay;
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
    if (kDebugMode) print("RAZORPAY SUCCESS: Payment ID: ${response.paymentId}, Order ID: ${response.orderId}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful: ${response.paymentId}'), backgroundColor: Colors.green),
    );
  }
  void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) print("RAZORPAY ERROR: Code: ${response.code}, Message: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.redAccent),
    );
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) print("RAZORPAY EXTERNAL WALLET: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}'), backgroundColor: Colors.blue),
    );
  }
  void _startRazorpayCheckout() {
    String name = getLocalizedText(widget.puja['name'], context.locale.languageCode);
    if (name.isEmpty) name = 'Premium Service';
    final double price = widget.puja['price'] != null
        ? (widget.puja['price'] is num ? (widget.puja['price'] as num).toDouble() : double.tryParse(widget.puja['price'].toString()) ?? 5100.0)
        : 5100.0;
    final int amountInPaise = (price * 100).toInt();
    final user = Supabase.instance.client.auth.currentUser;
    final String email = user?.email ?? '';
    final String phone = user?.userMetadata?['phone'] ?? '';
    var options = {
      'key': dotenv.env['RAZORPAY_TEST_KEY'] ?? '',
      'amount': amountInPaise,
      'name': 'VedicReeti',
      'description': name,
      'prefill': {
        'contact': phone,
        'email': email
      },
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      if (kDebugMode) print("DEBUG: Launching Razorpay for amount: $amountInPaise paise");
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error launching Razorpay: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    String name = getLocalizedText(widget.puja['name'], context.locale.languageCode);
    if (name.isEmpty) name = 'Premium Service';
    String desc = getLocalizedText(widget.puja['description'], context.locale.languageCode);
    if (desc.isEmpty) desc = 'Authentic Vedic Ritual';
    final String? imageUrl = widget.puja['image_url']?.toString();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF2A241D) : Colors.white,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: GoogleFonts.playfairDisplay(
                  color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF2A241D) : Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [const Shadow(color: Colors.white, blurRadius: 10)],
                ),
              ),
              background: Hero(
                tag: "puja_image_${widget.puja['id'] ?? name}",
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: const BoxDecoration(color: Color(0xFFF5EFE6)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.self_improvement_rounded,
                                    size: 50,
                                    color: Color(0xFF6B6258),
                                  ),
                                ),
                          )
                        else
                          const Center(
                            child: Icon(
                              Icons.self_improvement_rounded,
                              size: 50,
                              color: Color(0xFF6B6258),
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Theme.of(context).scaffoldBackgroundColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Details',
                    style: GoogleFonts.playfairDisplay(
                      color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF2A241D) : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    desc,
                    style: GoogleFonts.montserrat(
                      color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF6B6258) : Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFFFFFFF).withOpacity(0.95) : const Color(0xFF1E1E1E).withOpacity(0.95),
          border: const Border(
            top: BorderSide(
              color: Color(0xFFE7D8B1),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              if (kDebugMode) print("DEBUG: 'ui.book_now'.tr() button was clicked!");
              final user = Supabase.instance.client.auth.currentUser;
              if (user == null) {
                if (kDebugMode) print("DEBUG: User is null, opening Auth Bottom Sheet...");
                AuthBottomSheet.show(context);
              } else {
                if (kDebugMode) print("DEBUG: User authenticated (${user.email}), launching Razorpay...");
                _startRazorpayCheckout();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A227),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC9A227).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'ui.book_now'.tr(),
                style: GoogleFonts.montserrat(
                  color: const Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
