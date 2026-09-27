import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Biometric Authentication
  Future<bool> authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      bool isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) return false;

      return await _auth.authenticate(
        localizedReason: 'Media Vault আনলক করতে আপনার ফিঙ্গারপ্রিন্ট দিন',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Save 6-Digit PIN
  Future<void> savePin(String pin) async {
    if (pin.length == 6) {
      await _storage.write(key: 'user_pin', value: pin);
    }
  }

  // Validate 6-Digit PIN
  Future<bool> verifyPin(String inputPin) async {
    String? storedPin = await _storage.read(key: 'user_pin');
    return storedPin == inputPin;
  }

  // Check if PIN is already set
  Future<bool> isPinSet() async {
    String? storedPin = await _storage.read(key: 'user_pin');
    return storedPin != null;
  }
}
