import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
class SecurityService {
  static Future<void> checkDeviceIntegrity(BuildContext context) async {
    bool jailbroken = false;
    bool developerMode = false;
    try {
      developer.log('Checking device integrity...', name: 'SecurityService');
      jailbroken = await FlutterJailbreakDetection.jailbroken;
      developerMode = await FlutterJailbreakDetection.developerMode;
      developer.log('Integrity Check Complete: Jailbroken=$jailbroken, DevMode=$developerMode', name: 'SecurityService');
    } on PlatformException catch (e, stackTrace) {
      developer.log('PlatformException during integrity check', name: 'SecurityService', error: e, stackTrace: stackTrace);
      jailbroken = true;
    } catch (e, stackTrace) {
      developer.log('Unknown error during integrity check', name: 'SecurityService', error: e, stackTrace: stackTrace);
      jailbroken = true;
    }
    if (jailbroken || (developerMode && Platform.isAndroid)) {
      developer.log('Security violation detected. Halting application.', name: 'SecurityService');
      _showSecurityAlert(context);
    }
  }
  static void _showSecurityAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Security Alert', style: TextStyle(color: Colors.red)),
            content: const Text('This app cannot run on rooted, jailbroken, or compromised devices due to security policies.'),
            actions: [
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else {
                    exit(0);
                  }
                },
                child: const Text('EXIT APP'),
              ),
            ],
          ),
        );
      },
    );
  }
}
