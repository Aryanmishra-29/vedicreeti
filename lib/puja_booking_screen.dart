import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'utils/localization_helper.dart';
import 'auth_bottom_sheet.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'booking_success_screen.dart';
import 'cache_service.dart';
import 'widgets/offline_retry_banner.dart';
import 'widgets/puja_skeleton_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class PujaBookingScreen extends StatefulWidget {
  const PujaBookingScreen({super.key});
  @override
  State<PujaBookingScreen> createState() => _PujaBookingScreenState();
}
class _PujaBookingScreenState extends State<PujaBookingScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> allPujas = [];
  List<dynamic> filteredPujas = [];
  bool isLoading = true;
  bool isOffline = false;
  static const Color midnightObsidian = Color(0xFF0A0A0C);
  static const Color darkCard = Color(0xFF141416);
  static const Color champagneGold = Color(0xFFD4AF37);
  static const Color champagneLight = Color(0xFFF1D592);
  static const Color offWhite = Color(0xFFE8E8E8);

  Color get _dynamicGold => Theme.of(context).brightness == Brightness.dark ? champagneGold : const Color(0xFFB8860B);
  Color get _dynamicHeader => Theme.of(context).brightness == Brightness.dark ? champagneLight : const Color(0xFF8B6508);
  Color get _dynamicText => Theme.of(context).brightness == Brightness.dark ? midnightObsidian : const Color(0xFFFDFDFD);
  Color get _dynamicCard => Theme.of(context).brightness == Brightness.dark ? darkCard : Colors.white;

  final Map<String, String> _multilingualSearchMap = {
    '�-��؅': 'ganesh',
    '��_�,��?': 'shanti',
    '�"��-�?��1': 'navgrah',
    '�r��?�_�?�,�o�_': 'mrityunjay',
    '��-��_�r�?�-�?': 'baglamukhi',
    '�r�,�-�3': 'mangal',
    '�r�,�-��': 'mangal',
    '�_�o�?�z': 'yagy',
    '��<�-': 'rog',
    '�"��s�,��?': 'navchandi',
  };
  @override
  void initState() {
    super.initState();
    fetchPujas();
  }
  Future<void> fetchPujas() async {
    setState(() {
      isLoading = true;
      isOffline = false;
    });
    try {
      final dynamic response = await Supabase.instance.client
          .from('services')
          .select();
      setState(() {
        if (response != null && response is List) {
          allPujas = response;
          filteredPujas = response;
          CacheService.saveCache('pujas', response);
        } else {
          allPujas = [];
          filteredPujas = [];
        }
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('Error fetching services: $e');
      final cachedPujas = await CacheService.loadCache('pujas');
      setState(() {
        if (cachedPujas != null) {
          allPujas = cachedPujas;
          filteredPujas = cachedPujas;
        } else {
          allPujas = [];
          filteredPujas = [];
        }
        isOffline = true;
        isLoading = false;
      });
    }
  }
  void runFilter(String enteredKeyword) {
    String query = enteredKeyword.toLowerCase().trim();
    _multilingualSearchMap.forEach((nativeWord, englishTarget) {
      if (query.contains(nativeWord)) {
        query = query.replaceAll(nativeWord, englishTarget);
      }
    });
    List<dynamic> results = [];
    if (query.isEmpty) {
      results = allPujas;
    } else {
      results = allPujas.where((puja) {
        final name = getLocalizedText(puja['name'], context.locale.languageCode).toLowerCase();
        final desc = getLocalizedText(puja['description'], context.locale.languageCode).toLowerCase();
        return name.contains(query) || desc.contains(query);
      }).toList();
    }
    setState(() {
      filteredPujas = results;
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'search_pujas'.tr(),
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            fontSize: 28,
            color: champagneLight,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: champagneGold.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 100,
                    color: champagneGold.withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                OfflineRetryBanner(isVisible: isOffline, onRetry: fetchPujas),
                _buildSearchBar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, // Dark Grey / Obsidian Filled
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: champagneGold.withOpacity(0.3), width: 1),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => runFilter(value),
          style: GoogleFonts.montserrat(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search divine services...',
            hintStyle: GoogleFonts.montserrat(color: Colors.white54),
            prefixIcon: const Icon(Icons.search_rounded, color: champagneGold),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
  Widget _buildMainContent() {
    if (isLoading) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: 3,
        itemBuilder: (context, index) => const PujaCardSkeleton(),
      );
    }
    if (filteredPujas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: champagneGold,
              ),
              const SizedBox(height: 16),
              Text(
                'No pujas found matching your search.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: champagneGold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: filteredPujas.length,
      cacheExtent: 500.0, // Strict memory boundary for off-screen items
      addAutomaticKeepAlives: false, // Purge off-screen state immediately
      addRepaintBoundaries: true, // Isolate scroll repaints
      itemBuilder: (context, index) {
        return _buildLuxuryPujaCard(context, filteredPujas[index]);
      },
    );
  }
  Widget _buildLuxuryPujaCard(BuildContext context, dynamic puja) {
    String name = getLocalizedText(puja['name'], context.locale.languageCode);
    if (name.isEmpty) name = 'Premium Service';
    String desc = getLocalizedText(puja['description'], context.locale.languageCode);
    if (desc.isEmpty) desc = 'Authentic Vedic Ritual';
    final String? imageUrl = puja['image_url']?.toString();
    final double price = puja['price'] != null
        ? (puja['price'] is num
              ? (puja['price'] as num).toDouble()
              : double.tryParse(puja['price'].toString()) ?? 5100.0)
        : 5100.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: champagneGold.withOpacity(0.3), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: "puja_image_${puja['id'] ?? name}",
                  child: Material(
                    color: Colors.transparent,
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, _) =>
                                _buildGlowingPlaceholder(),
                          )
                        : _buildGlowingPlaceholder(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        darkCard.withOpacity(0.8),
                        darkCard,
                      ],
                      stops: const [0.4, 0.8, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _dynamicHeader,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: champagneGold.withOpacity(0.1),
                        border: Border.all(
                          color: champagneGold.withOpacity(0.4),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '�,1${price.toStringAsFixed(0)}',
                        style: GoogleFonts.montserrat(
                          color: champagneGold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      if (kDebugMode) print("DEBUG: User not logged in. Opening login sheet.");
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) =>
                            const AuthBottomSheet(), // Replace with your exact auth sheet widget name
                      );
                    } else {
                      if (kDebugMode) {
                        print(
                        "DEBUG: User logged in as ${user.email}. Moving to checkout.",
                      );
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LuxuryStepperScreen(
                            pujaName: name,
                            pujaPrice: price,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: champagneGold,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: champagneGold.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'book_now'.tr() == 'book_now'
                          ? 'ui.book_now'.tr()
                          : 'book_now'.tr(),
                      style: GoogleFonts.montserrat(
                        color: _dynamicText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGlowingPlaceholder() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1A1A1D)),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: champagneGold.withOpacity(0.05),
            boxShadow: [
              BoxShadow(
                color: champagneGold.withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.self_improvement_rounded,
            size: 50,
            color: champagneGold,
          ),
        ),
      ),
    );
  }
}
class LuxuryStepperScreen extends StatefulWidget {
  final String pujaName;
  final double pujaPrice;
  const LuxuryStepperScreen({
    super.key,
    required this.pujaName,
    required this.pujaPrice,
  });
  @override
  State<LuxuryStepperScreen> createState() => _LuxuryStepperScreenState();
}
class _LuxuryStepperScreenState extends State<LuxuryStepperScreen> {
  int _currentStep = 0;
  DateTime? _selectedDate;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gotraController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  DateTime? dobDate;
  bool isMarried = false;
  bool _isNameReadOnly = true;
  final FocusNode _nameFocusNode = FocusNode();
  late Razorpay _razorpay;
  bool _isProcessing = false;
  bool _saveToProfile = false;

  Color get _dynamicGold => Theme.of(context).brightness == Brightness.dark ? _PujaBookingScreenState.champagneGold : const Color(0xFFB8860B);
  Color get _dynamicHeader => Theme.of(context).brightness == Brightness.dark ? _PujaBookingScreenState.champagneLight : const Color(0xFF8B6508);
  Color get _dynamicOutline => Theme.of(context).brightness == Brightness.dark ? _PujaBookingScreenState.champagneGold.withOpacity(0.5) : const Color(0xFFB8860B);
  Color get _dynamicText => Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF2C2C2C);
  Color get _dynamicMutedText => Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  void _showAutofillBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ui.autofill_title'.tr(),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.person, color: _PujaBookingScreenState.champagneGold, size: 28),
                title: Text(
                  'ui.use_saved_profile'.tr(),
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ?? Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ?? 'Guest User', style: const TextStyle(color: Colors.grey)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: _PujaBookingScreenState.champagneGold.withOpacity(0.3)),
                ),
                tileColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _isNameReadOnly = true);
                  _autofillProfile();
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)),
                title: Text(
                  'ui.enter_manually'.tr(),
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                tileColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _isNameReadOnly = false);
                  _nameFocusNode.requestFocus();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  Future<void> _autofillProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata ?? {};
      setState(() {
        nameController.text = meta['full_name'] ?? meta['name'] ?? '';
        gotraController.text = meta['gotra'] ?? '';
        if (meta['dob'] != null && meta['dob'].toString().isNotEmpty) {
          dobDate = DateTime.tryParse(meta['dob'].toString());
        }
        isMarried = meta['is_married'] == true;
      });
      if (nameController.text.isNotEmpty || gotraController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile details autofilled!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved profile found.'), backgroundColor: Colors.orange),
        );
      }
    }
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = Supabase.instance.client.auth.currentUser;
    String targetPanditId = 'dummy_pandit_id_123';
    String panditName = 'Acharya Vidyasagar';
    String panditContact = '+91 9876543210';
    String specialization = 'Vedic Astrology & Vastu Shastra';
    
    try {
      final pandits = await Supabase.instance.client.from('pandits').select().limit(1);
      if (pandits.isNotEmpty) {
        final p = pandits.first;
        targetPanditId = p['id']?.toString() ?? targetPanditId;
        panditName = p['name'] ?? panditName;
        panditContact = p['phone_number'] ?? panditContact;
        if (p['expertise'] is List) {
           specialization = (p['expertise'] as List).join(', ');
        } else if (p['expertise'] is String) {
           specialization = p['expertise'];
        }
      }
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error fetching pandit: $e');
    }
    
    final String formattedDate = _selectedDate!.toIso8601String().split('T')[0];
    try {
      await Supabase.instance.client.from('bookings').insert({
        'user_id': user?.id,
        'pandit_id': targetPanditId,
        'booking_date': formattedDate,
        'status': 'confirmed',
        'payment_id': response.paymentId,
        'amount': widget.pujaPrice,
        'service_name': widget.pujaName,
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              panditName: panditName,
              panditContact: panditContact,
              specialization: specialization,
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error saving booking to Supabase: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              panditName: panditName,
              panditContact: panditContact,
              specialization: specialization,
            ),
          ),
        );
      }
    }
  }
  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Payment Failed. Please try again.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B0000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}'), backgroundColor: Colors.blue),
    );
  }
  Future<void> _processBooking() async {
    setState(() => _isProcessing = true);
    String targetPanditId = 'dummy_pandit_id_123';
    
    try {
      final pandits = await Supabase.instance.client.from('pandits').select('id').limit(1);
      if (pandits.isNotEmpty) {
        targetPanditId = pandits.first['id']?.toString() ?? targetPanditId;
      }
    } catch (e) {
      if (kDebugMode) print('DEBUG: Error fetching pandit id: $e');
    }
    
    final String formattedDate = _selectedDate!.toIso8601String().split('T')[0];
    try {
      final conflictCheck = await Supabase.instance.client
          .from('bookings')
          .select('id')
          .eq('pandit_id', targetPanditId)
          .eq('booking_date', formattedDate)
          .eq('status', 'confirmed');
      if (conflictCheck.isNotEmpty) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected Pandit is busy on this date. Please select another date.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    } catch (e) {
      if (kDebugMode) print("DEBUG: Checking conflict failed (table might not exist). Proceeding... $e");
    }
    final int amountInPaise = (widget.pujaPrice * 100).toInt();
    final user = Supabase.instance.client.auth.currentUser;
    final String email = user?.email ?? '';
    final String phone = user?.userMetadata?['phone'] ?? '';
    var options = {
      'key': dotenv.env['RAZORPAY_TEST_KEY'] ?? '',
      'amount': amountInPaise,
      'name': 'VedicReeti',
      'description': widget.pujaName,
      'prefill': {
        'contact': phone,
        'email': email
      },
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error launching Razorpay: $e');
      setState(() => _isProcessing = false);
    }
  }
  @override
  void dispose() {
    _razorpay.clear();
    nameController.dispose();
    gotraController.dispose();
    purposeController.dispose();
    super.dispose();
  }
  Future<void> _pickDate(BuildContext context) async {
    DateTime tempPickedDate = dobDate ?? DateTime.now().subtract(const Duration(days: 365 * 25));
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext builder) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 60), // Balance the 'Done' button
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(brightness: Brightness.dark),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: tempPickedDate,
                      minimumYear: 1900,
                      maximumYear: DateTime.now().year,
                      onDateTimeChanged: (DateTime newDate) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          dobDate = newDate;
                        });
                        tempPickedDate = newDate;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'book_now'.tr() == 'book_now' ? 'ui.book_now'.tr() : 'book_now'.tr(),
          style: GoogleFonts.playfairDisplay(
            color: _dynamicHeader,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: _PujaBookingScreenState.champagneLight,
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _PujaBookingScreenState.champagneGold,
            surface: _PujaBookingScreenState.darkCard,
          ),
          canvasColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stepper(
          type: StepperType.horizontal,
          stepIconBuilder: (int stepIndex, StepState stepState) {
            final isActive = _currentStep >= stepIndex;
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? _PujaBookingScreenState.champagneGold : Colors.grey.withOpacity(0.3),
                boxShadow: isActive ? [BoxShadow(color: _PujaBookingScreenState.champagneGold.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)] : null,
              ),
              child: Center(
                child: stepState == StepState.complete
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text('${stepIndex + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            );
          },
          currentStep: _currentStep,
          elevation: 0,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () async {
            if (_currentStep == 0) {
              if (nameController.text.trim().isEmpty ||
                  gotraController.text.trim().isEmpty ||
                  dobDate == null ||
                  purposeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (_saveToProfile) {
                final user = Supabase.instance.client.auth.currentUser;
                if (user != null) {
                  final currentMeta = Map<String, dynamic>.from(user.userMetadata ?? {});
                  currentMeta['full_name'] = nameController.text.trim();
                  currentMeta['gotra'] = gotraController.text.trim();
                  currentMeta['dob'] = dobDate!.toIso8601String();
                  currentMeta['is_married'] = isMarried;
                  try {
                    await Supabase.instance.client.auth.updateUser(UserAttributes(data: currentMeta));
                  } catch (e) {
                    if (kDebugMode) print("Error saving profile: $e");
                  }
                }
              }
            }
            if (_currentStep == 1 && _selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please select a date',
                    style: GoogleFonts.montserrat(),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              );
              return;
            }
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            } else {
              _processBooking();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              Navigator.pop(context);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _PujaBookingScreenState.champagneGold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).scaffoldBackgroundColor))
                        : Text(
                        _currentStep == 2 ? 'ui.step_confirm'.tr() : 'ui.continue_btn'.tr(),
                        style: GoogleFonts.montserrat(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: _dynamicOutline,
                        ),
                      ),
                      child: Text(
                        'ui.back_btn'.tr(),
                        style: GoogleFonts.montserrat(
                          color: _dynamicHeader,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text(
                'ui.step_details'.tr(),
                style: GoogleFonts.montserrat(
                  color: _currentStep >= 0
                      ? _dynamicHeader
                      : _dynamicMutedText,
                  fontSize: 12,
                ),
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildLuxuryStepCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ui.selected_spiritual_service'.tr(),
                      style: GoogleFonts.montserrat(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.pujaName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _dynamicHeader,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ui.premium_service_desc'.tr(),
                      style: GoogleFonts.montserrat(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _autofillProfile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: _PujaBookingScreenState.champagneGold, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'ui.use_saved_profile'.tr(),
                                style: GoogleFonts.montserrat(
                                  color: _PujaBookingScreenState.champagneGold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          focusNode: _nameFocusNode,
                          readOnly: _isNameReadOnly,
                          onTap: () {
                            if (_isNameReadOnly) {
                              _showAutofillBottomSheet(context);
                            }
                          },
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            labelText: 'ui.full_name'.tr(),
                            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _PujaBookingScreenState.champagneGold, width: 1.5)),
                          )
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: gotraController,
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            labelText: 'ui.gotra'.tr(),
                            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _PujaBookingScreenState.champagneGold, width: 1.5)),
                          )
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: ValueKey(dobDate),
                          initialValue: dobDate == null ? '' : '${dobDate!.toLocal()}'.split(' ')[0],
                          readOnly: true,
                          onTap: () => _pickDate(context),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            labelText: 'ui.dob'.tr(),
                            hintText: 'Tap to select date',
                            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _PujaBookingScreenState.champagneGold, width: 1.5)),
                            suffixIcon: const Icon(Icons.calendar_month_rounded, color: _PujaBookingScreenState.champagneGold),
                          )
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                          ),
                          tileColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          title: Text('ui.is_married'.tr(), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                          value: isMarried,
                          onChanged: (val) => setState(() => isMarried = val),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: purposeController,
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            labelText: 'ui.puja_sankalp'.tr(),
                            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _PujaBookingScreenState.champagneGold, width: 1.5)),
                          )
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                          ),
                          tileColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          title: Text(
                            'Save these details to my profile for future bookings',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13),
                          ),
                          value: _saveToProfile,
                          activeColor: _PujaBookingScreenState.champagneGold,
                          checkColor: Colors.black,
                          side: BorderSide(
                            color: Theme.of(context).brightness == Brightness.light 
                                ? Colors.grey.shade600 
                                : Colors.grey.shade400,
                            width: 1.5,
                          ),
                          onChanged: (val) => setState(() => _saveToProfile = val ?? false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: Text(
                'ui.step_date'.tr(),
                style: GoogleFonts.montserrat(
                  color: _currentStep >= 1
                      ? _dynamicHeader
                      : _dynamicMutedText,
                  fontSize: 12,
                ),
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildLuxuryStepCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auspicious Date Selection',
                      style: GoogleFonts.montserrat(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                textScaler: const TextScaler.linear(1.0),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary:
                                        _PujaBookingScreenState.champagneGold,
                                    onPrimary:
                                        _PujaBookingScreenState.midnightObsidian,
                                    surface: _PujaBookingScreenState.darkCard,
                                    onSurface: _PujaBookingScreenState.offWhite,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                          },
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _PujaBookingScreenState.champagneGold
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: _PujaBookingScreenState.champagneGold,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _selectedDate == null
                                  ? 'Select a Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: _PujaBookingScreenState.offWhite,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: Text(
                'ui.step_confirm'.tr(),
                style: GoogleFonts.montserrat(
                  color: _currentStep >= 2
                      ? _dynamicHeader
                      : _dynamicMutedText,
                  fontSize: 12,
                ),
              ),
              isActive: _currentStep >= 2,
              content: _buildLuxuryStepCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Summary',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _dynamicHeader,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _summaryRow('Service', widget.pujaName),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    _summaryRow(
                      'ui.step_date'.tr(),
                      _selectedDate == null
                          ? 'None'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    _summaryRow(
                      'Amount',
                      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(widget.pujaPrice ?? 5100),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _summaryRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 15),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: GoogleFonts.montserrat(
              color: val.startsWith('�,1')
                  ? _PujaBookingScreenState.champagneGold
                  : _PujaBookingScreenState.offWhite,
              fontSize: val.startsWith('�,1') ? 16 : 14,
              fontWeight: val.startsWith('�,1')
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildLuxuryStepCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _PujaBookingScreenState.champagneGold.withOpacity(0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
