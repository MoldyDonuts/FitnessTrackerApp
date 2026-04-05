import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;
  String errorMessage = '';

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message ?? 'Authentication error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28).copyWith(top: 72, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // Eyebrow
                Text(
                  'YOUR JOURNEY STARTS HERE',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),

                // Hero headline
                Text(
                  isLogin ? 'WELCOME\nBACK.' : 'CREATE\nACCOUNT.',
                  style: GoogleFonts.lexend(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryContainer,
                    height: 0.95,
                    letterSpacing: -2.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isLogin
                      ? 'Sign in to keep crushing your goals.'
                      : 'Join Kinetic and start your fitness journey.',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
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
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onPrimaryContainer,
                        letterSpacing: 1,
                      ),
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
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
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
                      color: AppColors.errorContainer.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      errorMessage,
                      style: GoogleFonts.manrope(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 2,
          ),
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
            style: GoogleFonts.manrope(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.manrope(
                color: AppColors.onSurfaceVariant.withOpacity(0.4),
                fontSize: 16,
              ),
              prefixIcon:
                  Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 18),
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
