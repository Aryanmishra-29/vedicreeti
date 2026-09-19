import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../secure_checkout_service.dart';
class BookingCheckoutScreen extends StatefulWidget {
  final String pujaName;
  final double basePrice;
  const BookingCheckoutScreen({
    super.key,
    required this.pujaName,
    required this.basePrice,
  });
  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}
class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  final Color champagneGold = const Color(0xFFD4AF37);
  final Color obsidianBlack = const Color(0xFF09090A);
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gotraController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  DateTime? dob;
  bool isMarried = false;
  bool isProcessingPayment = false;
  bool _showRetryButton = false;
  String? _orderId;
  @override
  void dispose() {
    nameController.dispose();
    gotraController.dispose();
    purposeController.dispose();
    super.dispose();
  }
  final List<String> _dates = [
    "Wed, Jun 3",
    "Thu, Jun 4",
    "Fri, Jun 5",
    "Sat, Jun 6",
    "Sun, Jun 7",
  ];
  final List<String> _timeSlots = [
    "Abhijit Muhurat",
    "Amrit Kaal",
    "Brahma Muhurat",
    "Godhuli",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Checkout',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 1.0,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: champagneGold,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPujaSummary(),
            const SizedBox(height: 32),
            Text(
              'Select Auspicious Date & Muhurat',
              style: GoogleFonts.montserrat(
                color: champagneGold.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 20),
            _buildTimeSelector(),
            const SizedBox(height: 36),
            _buildUserDetailsForm(),
            const SizedBox(height: 36),
            _buildAddressSelector(),
            const SizedBox(height: 36),
            _buildBillingBreakdown(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildProceedButton(),
    );
  }
  Widget _buildPujaSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: champagneGold.withOpacity(0.3), width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.pujaName,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: champagneGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: champagneGold.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Text(
              '₹\${widget.basePrice.toStringAsFixed(0)}',
              style: GoogleFonts.montserrat(
                color: champagneGold,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDateSelector() {
    return SizedBox(
      height: 75,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = _selectedDateIndex == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedDateIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 85,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? champagneGold.withOpacity(0.08)
                    : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? champagneGold : Colors.white12,
                  width: isSelected ? 1.0 : 0.3,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dates[index].split(',')[0],
                    style: GoogleFonts.montserrat(
                      color: isSelected ? champagneGold : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dates[index].split(',')[1].trim(),
                    style: GoogleFonts.montserrat(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(_timeSlots.length, (index) {
        final isSelected = _selectedTimeIndex == index;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedTimeIndex = index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? champagneGold.withOpacity(0.08)
                  : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? champagneGold : Colors.white12,
                width: isSelected ? 1.0 : 0.3,
              ),
            ),
            child: Text(
              _timeSlots[index],
              style: GoogleFonts.montserrat(
                color: isSelected ? champagneGold : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }
  Widget _buildAddressSelector() {
    final user = Supabase.instance.client.auth.currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: champagneGold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pooja Location / Address',
                    style: GoogleFonts.montserrat(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  'Change',
                  style: GoogleFonts.montserrat(
                    color: champagneGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user != null)
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('user_addresses')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', user.id)
                  .limit(1),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Loading saved location...',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  );
                }
                final addresses = snapshot.data ?? [];
                if (addresses.isEmpty) {
                  return Text(
                    'Tap "Change" to add your first address.',
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  );
                }
                final address = addresses.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address['tag']?.toString().toUpperCase() ?? 'HOME',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address['full_address'] ?? 'No detail provided',
                      style: GoogleFonts.montserrat(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                );
              },
            )
          else
            Text(
              'Please login to retrieve address.',
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildBillingBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BILLING DETAILS',
          style: GoogleFonts.montserrat(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12, width: 0.3),
          ),
          child: Column(
            children: [
              _buildBillRow(
                'Ritual Dakshina',
                '₹\${widget.basePrice.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1, thickness: 0.3),
              const SizedBox(height: 12),
              _buildBillRow('Samagri & Logistics', 'Included', isGreen: true),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1, thickness: 0.3),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Payable',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹\${widget.basePrice.toStringAsFixed(0)}',
                    style: GoogleFonts.montserrat(
                      color: champagneGold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildBillRow(String title, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            color: isGreen
                ? const Color(0xFF6B8E23)
                : Colors.white, // Subtle green for 'Included'
            fontSize: 14,
            fontWeight: isGreen ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
  Widget _buildProceedButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GestureDetector(
          onTap: isProcessingPayment
              ? null
              : () {
                  HapticFeedback.heavyImpact();
                  if (_showRetryButton && _orderId != null) {
                    _handleRetry();
                  } else {
                    _handleBooking();
                  }
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: _showRetryButton ? Colors.redAccent : champagneGold,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (_showRetryButton ? Colors.redAccent : champagneGold).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: isProcessingPayment
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: obsidianBlack,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _showRetryButton ? 'Retry Verification' : 'Proceed to Divine Payment',
                    style: GoogleFonts.montserrat(
                      color: _showRetryButton ? Colors.white : obsidianBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
  Widget _buildUserDetailsForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YAJMAN DETAILS',
            style: GoogleFonts.montserrat(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField('Full Name', nameController, Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField('Gotra', gotraController, Icons.family_restroom_outlined),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: champagneGold,
                        onPrimary: obsidianBlack,
                        surface: const Color(0xFF1E1E1E),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() => dob = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: champagneGold, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    dob == null ? 'Date of Birth' : '${dob!.day}/${dob!.month}/${dob!.year}',
                    style: GoogleFonts.montserrat(
                      color: dob == null ? Colors.white54 : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_border, color: champagneGold, size: 20),
                    const SizedBox(width: 12),
                    Text('Married', style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 14)),
                  ],
                ),
                Switch(
                  value: isMarried,
                  onChanged: (val) => setState(() => isMarried = val),
                  activeThumbColor: champagneGold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Purpose of Pooja / Sankalpa', purposeController, Icons.handshake_outlined),
        ],
      ),
    );
  }
  Widget _buildTextField(String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.white54, fontSize: 14),
        prefixIcon: Icon(icon, color: champagneGold, size: 20),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: champagneGold),
        ),
      ),
    );
  }
  Future<void> _handleRetry() async {
    setState(() => isProcessingPayment = true);
    try {
      final isPaid = await SecureCheckoutService().verifyPaymentStatus(_orderId!);
      if (isPaid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification Successful! 🙏', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Payment is still pending. Please wait or try again.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessingPayment = false);
      }
    }
  }
  Future<void> _handleBooking() async {
    if (nameController.text.trim().isEmpty || gotraController.text.trim().isEmpty || dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all Yajman Details', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() {
      isProcessingPayment = true;
      _showRetryButton = false;
    });
    try {
      _orderId = await SecureCheckoutService().initiateCheckout(widget.basePrice);
      await Future.delayed(const Duration(seconds: 2));
      final successStream = SecureCheckoutService().listenForPaymentSuccess(_orderId!);
      try {
        final successList = await successStream.firstWhere((list) => list.isNotEmpty).timeout(const Duration(seconds: 5));
        if (successList.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment Successful & Booking Confirmed! 🙏', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        }
      } catch (timeoutException) {
        setState(() {
          _showRetryButton = true;
        });
        throw Exception('Network timeout verifying payment. Please retry.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessingPayment = false);
      }
    }
  }
}
