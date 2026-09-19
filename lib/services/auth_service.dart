import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: fullName != null ? {'full_name': fullName.trim()} : null,
      );
    } on AuthException catch (e) {
      final msgLower = e.message.toLowerCase();
      
      // Specifically check for existing user errors
      if (msgLower.contains('already registered') || 
          msgLower.contains('user_already_exists') || 
          e.statusCode == '422') {
        throw AppException('This email is already registered. Please sign in instead.');
      }
      
      // Fallback for other auth exceptions
      throw AppException(e.message);
    } catch (e) {
      // Catch any unexpected errors
      throw AppException('An unexpected error occurred. Please try again.');
    }
  }
}
