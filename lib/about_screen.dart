import 'package:flutter/material.dart';
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About VedicReeti'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Introduction',
              'Welcome to VedicReeti. These terms and conditions outline the rules and regulations for the use of the VedicReeti mobile application. By accessing this app, we assume you accept these terms and conditions. Do not continue to use VedicReeti if you do not agree to take all of the terms and conditions stated on this page.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '2. User Privacy',
              'Your privacy is critical to us. We respect your privacy regarding any information we may collect while operating our application. We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '3. Platform Usage',
              'The platform is intended to facilitate the booking of spiritual and religious services. Users must not use the application in any way that causes, or may cause, damage to the app or impairment of the availability or accessibility of the app; or in any way which is unlawful, illegal, fraudulent or harmful.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '4. Payment & Refunds',
              'All payments made for Puja services are processed securely. Refunds are subject to our cancellation policy. If a service is cancelled by the provider, a full refund will be initiated within 5-7 business days.',
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Last updated: May 2026\nVedicReeti v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
