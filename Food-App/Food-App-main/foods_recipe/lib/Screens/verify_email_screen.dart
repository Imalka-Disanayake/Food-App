import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'food-type-selection.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  // _isSending removed because we no longer show a manual resend button
  bool _isChecking = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Start a periodic check every 5 seconds to see if the user verified their email.
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkVerified());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
  Future<void> _checkVerified() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No signed-in user');
      await user.reload();
      final reloaded = FirebaseAuth.instance.currentUser;
      if (reloaded != null && reloaded.emailVerified) {
        // Update Firestore flag
        try {
          final users = FirebaseFirestore.instance.collection('users');
          await users.doc(reloaded.uid).set({'isVerified': true, 'lastSeen': DateTime.now().toIso8601String()}, SetOptions(merge: true));
        } catch (e) {
          if (kDebugMode) debugPrint('Failed to set isVerified: $e');
        }

        // Navigate to food type selection
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const FoodTypeSelectionScreen()));
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking verification: $e');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // App colors used elsewhere in the app
    final primary = const Color(0xFF1A2A66);
    final buttonBg = const Color.fromARGB(255, 209, 199, 177);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify your email'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'A verification email has been sent to your email address.\n\nPlease open the email and click the verification link. This screen will automatically detect verification and proceed.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Only show informational note and a styled Cancel button.
            Text(
              'Tip: If you don\'t see the email, check your spam folder.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: () async {
                // Sign out and go back to login
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (_) {}
                if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: buttonBg,
                foregroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Back to Login'),
            ),

            const Spacer(),
            const Text('This screen checks for verification every few seconds.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
