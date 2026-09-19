import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'screens/terms_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'services/auth_service.dart';
class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AuthBottomSheet(),
    );
  }
  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}
class _AuthBottomSheetState extends State<AuthBottomSheet> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isForgotPasswordMode = false;
  bool _agreedToTerms = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  static const Color midnightObsidian = Color(0xFF0A0A0A);
  static const Color champagneGold = Color(0xFFD4AF37);
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  Future<void> _handleAuth() async {
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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
                      color: Theme.of(context).brightness == Brightness.light ? champagneGold : const Color(0xFFF3E5AB),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      if (_isLogin) {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await AuthService().signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
        );
      }
      if (mounted) {
        Navigator.pop(context); // Close bottom sheet on success
      }
    } on AppException catch (e) {
      if (mounted) {
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
        _passwordController.clear();
        debugPrint('SUPABASE ERROR: ${e.message} | CODE: ${e.statusCode}');
        String errorMsg = 'Invalid credentials or input format provided.';
        final msgLower = e.message.toLowerCase();
        if (msgLower.contains('email not confirmed')) {
          errorMsg = 'Please verify your email address before logging in.';
        } else if (msgLower.contains('invalid login credentials')) {
          errorMsg = 'Incorrect email or password.';
        }
        _showEliteError(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        _passwordController.clear();
        debugPrint('UNEXPECTED ERROR: $e');
        _showEliteError('A secure connection could not be established. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showEliteError("Please enter your email address to reset your password.");
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.vedicreeti://reset-password',
      );
      if (mounted) {
        _showEliteError("Reset link sent successfully! Please check your email inbox.");
      }
    } catch (e) {
      if (mounted) {
        _showEliteError("Failed to send reset link. Please check if the email is correct.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  void _showEliteError(String message) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: champagneGold.withOpacity(0.5), width: 1.5),
          ),
          title: Row(
            children: [
              Icon(Icons.shield_outlined, color: champagneGold, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Security Alert',
                  style: GoogleFonts.montserrat(
                    color: champagneGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.montserrat(
              color: Theme.of(context).colorScheme.onSurface,
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                  color: Theme.of(context).colorScheme.surface,
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
                      if (!_isForgotPasswordMode) ...[
                        _buildTabSwitcher(),
                        const SizedBox(height: 36),
                      ] else ...[
                        Text(
                          'Reset Password',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: champagneGold,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuart,
                        child: (!_isLogin && !_isForgotPasswordMode)
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
                      if (!_isForgotPasswordMode) ...[
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
                              onTap: () => setState(() => _isForgotPasswordMode = true),
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
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                      if (_isForgotPasswordMode) ...[
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => setState(() => _isForgotPasswordMode = false),
                          child: Text(
                            "Back to Login",
                            style: GoogleFonts.montserrat(
                              color: champagneGold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      ],
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
  Widget _buildTabSwitcher() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.15) : Colors.black.withOpacity(0.4),
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
                    color: _isLogin ? champagneGold : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
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
                    color: !_isLogin ? champagneGold : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
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
      onTap: _isLoading ? null : (_isForgotPasswordMode ? _handleForgotPassword : _handleAuth),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [champagneGold, Color(0xFFE5C875), champagneGold],
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
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: midnightObsidian,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                _isForgotPasswordMode ? 'SEND RESET LINK' : (_isLogin ? 'LOGIN' : 'CREATE ACCOUNT'),
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
    final Color iconColor = _isFocused ? champagneGold : Theme.of(context).colorScheme.onSurface.withOpacity(0.38);
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.isPassword ? widget.obscureText : false,
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
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    widget.obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    key: ValueKey(widget.obscureText),
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                    size: 20,
                  ),
                ),
                onPressed: widget.onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.withOpacity(0.1)
            : Colors.black.withOpacity(0.25),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.1)
                : Colors.white.withOpacity(0.08),
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
