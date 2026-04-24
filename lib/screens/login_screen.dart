import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final _eyebrowStyle = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    letterSpacing: 3,
  );
  static final _headlineStyle = GoogleFonts.lexend(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryContainer,
    height: 0.95,
    letterSpacing: -2.5,
  );
  static final _subtitleStyle = GoogleFonts.manrope(
    fontSize: 14,
    color: AppColors.onSurfaceVariant,
    fontWeight: FontWeight.w500,
  );
  static final _fieldLabelStyle = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 2,
  );
  static final _fieldTextStyle = GoogleFonts.manrope(
    color: AppColors.onSurface,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static final _hintStyle = GoogleFonts.manrope(
    color: Color(0x66B0AE70),
    fontSize: 16,
  );
  static final _ctaStyle = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.onPrimaryContainer,
    letterSpacing: 1,
  );
  static final _toggleStyle = GoogleFonts.manrope(
    fontSize: 13,
    color: AppColors.onSurfaceVariant,
    fontWeight: FontWeight.w600,
  );
  static final _errorStyle = GoogleFonts.manrope(
    color: AppColors.error,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static const _errorContainerField = Color(0x40B92902);
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;
  String errorMessage = '';
///Authenticates the user with firebase admin
  ///handles both login and registration depending on [isLogin] state
  ///On success navigates to [MainShell]
  ///on failure displays error message from [FirebaseAuthException]
  ///Requirements: 1.0.0, 1.10,1.20,1.30,1.40,1.60




  Future<void> authenticate() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Please enter your email and password.');
      return;
    }
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
              'email': emailController.text.trim(),
              'createdAt': Timestamp.now(),
            });
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => errorMessage = e.message ?? 'Authentication error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
            ).copyWith(top: 72, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // Eyebrow
                Text(
                  'YOUR JOURNEY STARTS HERE',
                  style: _eyebrowStyle,
                ),
                const SizedBox(height: 10),

                // Hero headline
                Text(
                  isLogin ? 'WELCOME\nBACK.' : 'CREATE\nACCOUNT.',
                  style: _headlineStyle,
                ),
                const SizedBox(height: 14),
                Text(
                  isLogin
                      ? 'Sign in to keep crushing your goals.'
                      : 'Join Kinetic and start your fitness journey.',
                  style: _subtitleStyle,
                ),
                const SizedBox(height: 48),

                // Fields
                _field(
                  controller: emailController,
                  label: 'EMAIL',
                  hint: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _field(
                  controller: passwordController,
                  label: 'PASSWORD',
                  hint: '••••••••',
                  obscureText: true,
                  icon: Icons.lock_outline,
                ),
                const SizedBox(height: 36),

                // CTA
                GestureDetector(
                  onTap: authenticate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      isLogin ? 'LOGIN' : 'REGISTER',
                      textAlign: TextAlign.center,
                      style: _ctaStyle,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      isLogin = !isLogin;
                      errorMessage = '';
                    }),
                    child: Text(
                      isLogin
                          ? "Don't have an account?  REGISTER"
                          : 'Already have an account?  LOGIN',
                      style: _toggleStyle,
                    ),
                  ),
                ),

                // Error
                if (errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _errorContainerField,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      errorMessage,
                      style: _errorStyle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _fieldLabelStyle,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: _fieldTextStyle,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: _hintStyle,
              prefixIcon: Icon(
                icon,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
