import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/gestures.dart';
import 'screens/terms_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'services/auth_service.dart';
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  static const Color midnightObsidian = Color(0xFF0A0A0A);
  static const Color champagneGold = Color(0xFFD4AF37);
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  void _submit() async {
    if (!_agreedToTerms) {
      showDialog(
        context: context,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1E1E), Color(0xFF0A0A0A)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFD4AF37),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Consent Required',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFFF3E5AB),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please accept the Terms and Conditions and Privacy Policy to proceed.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFFA3A3A3),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8C00), Color(0xFFE65C00)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8C00).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Accept & Continue',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: CircularProgressIndicator(
            color: champagneGold,
            strokeWidth: 3,
          ),
        ),
      ),
    );
    try {
      if (_isLogin) {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await AuthService().signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
        );
      }
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        Navigator.of(context).pop(); // Dismiss AuthScreen
      }
    } on AppException catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        _passwordController.clear(); // 3. FOCUS RESET
        _showEliteError('Incorrect email or password. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        _passwordController.clear(); // 3. FOCUS RESET
        _showEliteError(
          'A secure connection could not be established. Please try again.',
        );
      }
    }
  }
  void _showEliteError(String message) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: champagneGold.withOpacity(0.5), width: 1.5),
          ),
          title: Row(
            children: [
              Icon(Icons.shield_outlined, color: champagneGold, size: 28),
              const SizedBox(width: 12),
              Text(
                'Security Alert',
                style: GoogleFonts.montserrat(
                  color: champagneGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'TRY AGAIN',
                style: GoogleFonts.montserrat(
                  color: champagneGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: midnightObsidian,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              Positioned(top: -100, left: -100, child: _buildGlowSphere()),
              Positioned(bottom: -100, right: -100, child: _buildGlowSphere()),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: _buildGlassmorphicCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildGlowSphere() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: champagneGold.withOpacity(0.12),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(color: Colors.transparent),
      ),
    );
  }
  Widget _buildGlassmorphicCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: champagneGold.withOpacity(0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
                _buildTabSwitcher(),
                const SizedBox(height: 36),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuart,
                  child: !_isLogin
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _PremiumTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (val) => val == null || val.isEmpty
                                ? 'Name is required'
                                : null,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                _PremiumTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _PremiumTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password is required';
                    }
                    if (val.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                if (_isLogin) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.montserrat(
                          color: champagneGold.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (val) {
                          setState(() {
                            _agreedToTerms = val ?? false;
                          });
                        },
                        activeColor: champagneGold,
                        checkColor: midnightObsidian,
                        side: BorderSide(color: champagneGold.withOpacity(0.5)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(
                                color: champagneGold,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TermsScreen()),
                                  );
                                },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: champagneGold,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                                  );
                                },
                            ),
                            const TextSpan(text: '\n(We collect data to provide accurate Panchang and secure E-commerce services)'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLuxuryButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTabSwitcher() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _isLogin
                      ? champagneGold.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isLogin
                        ? champagneGold.withOpacity(0.5)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Login',
                  style: GoogleFonts.montserrat(
                    color: _isLogin ? champagneGold : Colors.white54,
                    fontWeight: _isLogin ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: !_isLogin
                      ? champagneGold.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: !_isLogin
                        ? champagneGold.withOpacity(0.5)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.montserrat(
                    color: !_isLogin ? champagneGold : Colors.white54,
                    fontWeight: !_isLogin ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLuxuryButton() {
    return GestureDetector(
      onTap: _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [champagneGold, const Color(0xFFE5C875), champagneGold],
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
          _isLogin ? 'LOGIN' : 'CREATE ACCOUNT',
          style: GoogleFonts.montserrat(
            color: midnightObsidian,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
class _PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.onTogglePassword,
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
    final Color iconColor = _isFocused ? champagneGold : Colors.white38;
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.isPassword ? widget.obscureText : false,
      keyboardType: widget.keyboardType,
      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15),
      cursorColor: champagneGold,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: GoogleFonts.montserrat(
          color: _isFocused ? champagneGold : Colors.white54,
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
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    widget.obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    key: ValueKey(widget.obscureText),
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
                onPressed: widget.onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: Colors.black.withOpacity(0.25),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
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
