import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
class DeliveryDetailsSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  const DeliveryDetailsSheet({super.key, required this.onSubmit});
  static void show(BuildContext context, {required Function(Map<String, dynamic>) onSubmit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeliveryDetailsSheet(onSubmit: onSubmit),
    );
  }
  @override
  State<DeliveryDetailsSheet> createState() => _DeliveryDetailsSheetState();
}
class _DeliveryDetailsSheetState extends State<DeliveryDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityStateController = TextEditingController();
  bool _saveAddress = true;
  final bool _isLoading = true; // For SharedPreferences read
  static const Color midnightObsidian = Color(0xFF0A0A0A);
  static const Color champagneGold = Color(0xFFD4AF37);
  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _cityStateController.dispose();
    super.dispose();
  }
  Future<void> _loadSavedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDataStr = prefs.getString('saved_delivery_address');
      if (savedDataStr != null && savedDataStr.isNotEmpty) {
        final savedData = jsonDecode(savedDataStr) as Map<String, dynamic>;
        _nameController.text = savedData['name'] ?? '';
        _phoneController.text = savedData['phone'] ?? '';
        _pincodeController.text = savedData['pincode'] ?? '';
        _addressController.text = savedData['address'] ?? '';
        _cityStateController.text = savedData['city_state'] ?? '';
      }
    } catch (e) {
      debugPrint('Failed to load saved address: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_delivery_address');
    }
  }
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final formData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'address': _addressController.text.trim(),
      'city_state': _cityStateController.text.trim(),
      'is_dummy': false, // Ensuring edge function knows it's real
    };
    if (_saveAddress) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_delivery_address', jsonEncode(formData));
      } catch (e) {
      }
    }
    Navigator.pop(context);
    widget.onSubmit(formData);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: champagneGold.withOpacity(0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: champagneGold.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        'Delivery Details',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: champagneGold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Where should we send your sacred items?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _PremiumTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _PremiumTextField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _PremiumTextField(
                        controller: _pincodeController,
                        label: 'Pincode',
                        icon: Icons.location_on_outlined,
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _PremiumTextField(
                        controller: _addressController,
                        label: 'Delivery Address (House/Flat No, Street)',
                        icon: Icons.home_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _PremiumTextField(
                        controller: _cityStateController,
                        label: 'City & State',
                        icon: Icons.map_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => setState(() => _saveAddress = !_saveAddress),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _saveAddress ? champagneGold : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                                  width: 1.5,
                                ),
                                color: _saveAddress ? champagneGold.withOpacity(0.2) : Colors.transparent,
                              ),
                              child: _saveAddress
                                ? const Icon(Icons.check, size: 16, color: champagneGold)
                                : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Save address to profile for future orders',
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      GestureDetector(
                        onTap: _handleSubmit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 54,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [champagneGold, Color(0xFFE5C875), champagneGold],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: champagneGold.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'PROCEED TO PAYMENT',
                            style: GoogleFonts.montserrat(
                              color: midnightObsidian,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }
}
class _PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });
  @override
  State<_PremiumTextField> createState() => _PremiumTextFieldState();
}
class _PremiumTextFieldState extends State<_PremiumTextField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    const Color champagneGold = Color(0xFFD4AF37);
    final Color iconColor = _isFocused ? champagneGold : Theme.of(context).colorScheme.onSurface.withOpacity(0.38);
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      style: GoogleFonts.montserrat(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
      cursorColor: champagneGold,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: GoogleFonts.montserrat(
          color: _isFocused ? champagneGold : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
          fontSize: 14,
        ),
        prefixIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            widget.icon,
            key: ValueKey(_isFocused),
            color: iconColor,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: champagneGold.withOpacity(0.8),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.redAccent.withOpacity(0.7),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.redAccent.withOpacity(0.9),
            width: 1.5,
          ),
        ),
        errorStyle: GoogleFonts.montserrat(
          color: Colors.redAccent,
          fontSize: 12,
        ),
      ),
      validator: widget.validator,
    );
  }
}
