import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food-type-selection.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isSending = false;
  bool _isChecking = false;

  Future<void> _sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      setState(() => _isSending = true);
      await user.sendEmailVerification();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent')));
    } catch (e) {
      if (kDebugMode) debugPrint('sendEmailVerification error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send verification email: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _checkVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      setState(() => _isChecking = true);
      await user.reload();
      final reloaded = FirebaseAuth.instance.currentUser;
      if (reloaded != null && reloaded.emailVerified) {
        // Update Firestore user doc
        try {
          final users = FirebaseFirestore.instance.collection('users');
          await users.doc(reloaded.uid).set({
            'isVerified': true,
            'lastSeen': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        } catch (e) {
          if (kDebugMode) debugPrint('Failed to set isVerified in user doc: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email verified — continuing')));
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const FoodTypeSelectionScreen()));
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email not verified yet')));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('checkVerified error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error checking verification: $e')));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text('A verification email was sent to your email address.\nPlease open it and click the verification link.', textAlign: TextAlign.left),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSending ? null : _sendVerificationEmail,
              child: _isSending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Resend verification email'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isChecking ? null : _checkVerified,
              child: _isChecking ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('I have verified — continue'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                // allow user to sign out and go back to login
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Cancel and sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
