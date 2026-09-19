import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      if (!canAuthenticate) {
        return false;
      }
      authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to access this secure area',
        biometricOnly: true,
      );
    } on PlatformException {
      return false;
    }
    return authenticated;
  }
}
