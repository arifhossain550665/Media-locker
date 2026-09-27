import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _pinController = TextEditingController();
  bool _isPinCreated = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    bool pinSet = await _authService.isPinSet();
    setState(() => _isPinCreated = pinSet);

    if (pinSet) {
      _triggerBiometric();
    }
  }

  void _triggerBiometric() async {
    bool authenticated = await _authService.authenticateWithBiometrics();
    if (authenticated && mounted) {
      _navigateToHome();
    }
  }

  void _handlePinSubmit() async {
    String input = _pinController.text;
    if (input.length != 6) return;

    if (!_isPinCreated) {
      await _authService.savePin(input);
      _navigateToHome();
    } else {
      bool isValid = await _authService.verifyPin(input);
      if (isValid) {
        _navigateToHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ভুল PIN দিয়েছেন!')),
        );
        _pinController.clear();
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            Text(
              _isPinCreated ? 'Enter 6-Digit PIN' : 'Set New 6-Digit PIN',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                counterText: '',
              ),
              onChanged: (val) {
                if (val.length == 6) _handlePinSubmit();
              },
            ),
            if (_isPinCreated) ...[
              const SizedBox(height: 30),
              IconButton(
                icon: const Icon(Icons.fingerprint, size: 50, color: Colors.blueAccent),
                onPressed: _triggerBiometric,
              )
            ]
          ],
        ),
      ),
    );
  }
}
