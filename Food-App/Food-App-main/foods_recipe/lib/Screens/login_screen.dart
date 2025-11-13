import 'package:flutter/material.dart';
import 'create_account_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dashboard_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _remember = false;
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in cancelled')));
        return;
      }

      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? user;
      try {
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        user = userCredential.user;
      } catch (e) {
        user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firebase sign-in failed: $e')));
          return;
        }
      }

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
        return;
      }

      try {
        final users = FirebaseFirestore.instance.collection('users');
        final doc = await users.doc(user.uid).get();
        if (!doc.exists) {
          await users.doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email,
            'photoUrl': user.photoURL ?? '',
            'lastSeen': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Failed creating user doc on Google sign-in: $e');
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign-in error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null) throw Exception('No user returned');

      try {
        final users = FirebaseFirestore.instance.collection('users');
        final doc = await users.doc(user.uid).get();
        if (!doc.exists) {
          await users.doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Failed creating user doc on login: $e');
      }

      // Only allow login to proceed if email is verified
      await user.reload();
      final reloaded = FirebaseAuth.instance.currentUser;
      if (reloaded != null && reloaded.emailVerified) {
        // Mark verified in Firestore (merge)
        try {
          await FirebaseFirestore.instance.collection('users').doc(reloaded.uid).set({'isVerified': true, 'lastSeen': DateTime.now().toIso8601String()}, SetOptions(merge: true));
        } catch (_) {}

        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        // Not verified: navigate to verify screen so user can resend/check.
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'isVerified': false}, SetOptions(merge: true));
        } catch (_) {}
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please verify your email before logging in.')));
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const VerifyEmailScreen()));
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed';
      if (e.code == 'user-not-found') msg = 'No user found for that email.';
      if (e.code == 'wrong-password') msg = 'Wrong password provided.';
      if (e.code == 'user-disabled') msg = 'This user has been disabled.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$msg ${e.message ?? ''}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1A2A66);
    final buttonBg = const Color.fromARGB(255, 209, 199, 177);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'lib/assests/login_image.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text('Image not found', style: TextStyle(color: Colors.red)),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 12,
                  right: 12,
                  child: SafeArea(
                    top: true,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: buttonBg,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Icon(Icons.arrow_back_ios, color: primary, size: 20),
                            ),
                          ),

                          SizedBox(
                            height: 36,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateAccountScreen())),
                              style: TextButton.styleFrom(
                                backgroundColor: buttonBg,
                                foregroundColor: primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                minimumSize: const Size(64, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: const Text('Sign Up', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Welcome Back to\nFull Bellies Empty Bins',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Your Email',
                        hintStyle: const TextStyle(color: Colors.black54),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFFD6B357))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFFD6B357), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Colors.black54),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFFD6B357))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFFD6B357), width: 2)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Switch(value: _remember, onChanged: (v) => setState(() => _remember = v), activeColor: primary),
                        const SizedBox(width: 6),
                        const Text('Remember', style: TextStyle(fontSize: 12)),
                        const Spacer(),
                        TextButton(onPressed: () {}, child: const Text('Forgot?', style: TextStyle(color: Colors.black54))),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Center(
                        child: SizedBox(
                        width: 260,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(backgroundColor: buttonBg, foregroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // OR divider
                    Row(children: const [Expanded(child: Divider(thickness: 1, color: Colors.black26)), Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('OR', style: TextStyle(color: Colors.black54))), Expanded(child: Divider(thickness: 1, color: Colors.black26))]),
                    const SizedBox(height: 12),

                    Center(
                      child: SizedBox(
                        width: 260,
                        height: 48,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Colors.black), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 12)),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.g_mobiledata, color: Color(0xFFDB4437)), SizedBox(width: 12), Text('Sign In with Google', style: TextStyle(color: Colors.black87))]),
            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(child: Text('Term of Use and Privacy Policy', style: TextStyle(fontSize: 12, color: Colors.black54))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
