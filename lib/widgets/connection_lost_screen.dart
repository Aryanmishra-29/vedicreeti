import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectionLostScreen extends StatefulWidget {
  final VoidCallback onRetry;

  const ConnectionLostScreen({super.key, required this.onRetry});

  @override
  State<ConnectionLostScreen> createState() => _ConnectionLostScreenState();
}

class _ConnectionLostScreenState extends State<ConnectionLostScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Ethereal Backgrounds (Theme Aware)
    final centerColor = isDarkMode ? const Color(0xFF2A2211) : const Color(0xFFF9F6E8);
    final edgeColor = isDarkMode ? const Color(0xFF050505) : const Color(0xFFFDFDFD);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [centerColor, edgeColor],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 'Breathing' Lotus Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: Color(0xFFD4AF37),
                      size: 64,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          
          // Poetic Typography - Title
          Text(
            'A Moment of Stillness',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFD4AF37),
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Poetic Typography - Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'The cosmic threads are aligning.\nPlease check your network to resume your spiritual journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 56),
          
          // Tactile 'Reconnect' Button
          OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onRetry();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              backgroundColor: Colors.transparent,
            ),
            child: const Text(
              'Awaken Connection',
              style: TextStyle(
                color: Color(0xFFD4AF37), 
                fontSize: 16,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
