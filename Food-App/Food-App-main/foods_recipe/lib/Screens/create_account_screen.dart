
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'food-type-selection.dart';
import 'verify_email_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool _isSigningIn = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();

      setState(() {
        _isLoading = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Creating account...')));
      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = userCredential.user;

        if (user != null) {
          await user.updateDisplayName(name);

          try {
            final users = FirebaseFirestore.instance.collection('users');
            await users.doc(user.uid).set({
              'uid': user.uid,
              'name': name,
              'email': user.email ?? _emailController.text.trim(),
              'isVerified': false,
              'lastSeen': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          } catch (e) {
            if (kDebugMode) debugPrint('Failed to write user doc after registration: $e');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created but failed to save user info: $e')));
          }

          // Send email verification and navigate to verify screen
          try {
            await user.sendEmailVerification();
          } catch (e) {
            if (kDebugMode) debugPrint('Failed sending verification email: $e');
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created — verification email sent')));
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const VerifyEmailScreen()));
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Registration failed';
        if (e.code == 'email-already-in-use') message = 'Email already in use';
        if (e.code == 'weak-password') message = 'Password is too weak';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$message: ${e.message}')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true;
      _isLoading = true;
    });

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
      } catch (e, st) {

        if (kDebugMode) debugPrint('signInWithCredential threw: $e\n$st');
        user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firebase sign-in failed: $e')));
          return;
        }
      }


      final signedInUser = user!;
      if (signedInUser.emailVerified) {
        final users = FirebaseFirestore.instance.collection('users');
        if (kDebugMode) debugPrint('Updating user doc at users/${signedInUser.uid} for email=${signedInUser.email}');
        try {
          await users.doc(signedInUser.uid).set({
            'uid': signedInUser.uid,
            'name': signedInUser.displayName ?? _nameController.text.trim(),
            'email': signedInUser.email ?? account.email,
            'photoUrl': signedInUser.photoURL ?? account.photoUrl,
            'lastSeen': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        } catch (e, st) {
          if (kDebugMode) debugPrint('Failed writing user doc users/${signedInUser.uid}: $e\n$st');
          if (e is FirebaseException && e.code == 'permission-denied') {
            final msg = 'Permission denied writing users/${signedInUser.uid}';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
            return;
          }
          rethrow;
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signed in as ${signedInUser.email}')));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const FoodTypeSelectionScreen()));
      } else {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firebase Auth error: ${e.message}')));
    } catch (e, st) {
      if (kDebugMode) debugPrint('Google sign-in error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      setState(() {
        _isSigningIn = false;
        _isLoading = false;
      });
    }
  }


  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final emailPattern = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
    if (!emailPattern.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
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
                  'lib/assests/new_acc_image.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text(
                      'Image not found',
                      style: TextStyle(color: Colors.red),
                    ),
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
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            ),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: buttonBg,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: primary,
                                size: 20,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 36,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: buttonBg,
                                foregroundColor: primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                minimumSize: const Size(64, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Let's start making good\n meals",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              hintStyle: const TextStyle(color: Colors.black54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: const Color(0xFFD6B357)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: const Color(0xFFD6B357), width: 2),
                              ),
                            ),
                            validator: _validateName,
                          ),
                          const SizedBox(height: 18),
                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Your Email',
                              hintStyle: const TextStyle(color: Colors.black54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color(0xFFD6B357),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color(0xFFD6B357),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 18),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: const TextStyle(color: Colors.black54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color(0xFFD6B357),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color(0xFFD6B357),
                                  width: 2,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: SizedBox(
                              width: 260,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonBg,
                                  foregroundColor: primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: const [
                              Expanded(child: Divider(thickness: 1, color: Colors.black26)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text('OR', style: TextStyle(color: Colors.black54)),
                              ),
                              Expanded(child: Divider(thickness: 1, color: Colors.black26)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: SizedBox(
                              width: 260,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: _isSigningIn ? null : _handleGoogleSignIn,
                                style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 245, 237, 237),
                                    side: const BorderSide(color: Colors.black),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                child: _isSigningIn
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437)),
                                          const SizedBox(width: 12),
                                          const Text('Sign Up with Google', style: TextStyle(color: Colors.black87)),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              'Term of Use and Privacy Policy',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
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
