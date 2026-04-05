import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class AppColors {
  static const background           = Color(0xFF0F0F00);
  static const surfaceContainerLow  = Color(0xFF151400);
  static const surfaceContainer     = Color(0xFF1B1B00);
  static const surfaceContainerHigh = Color(0xFF212100);
  static const surfaceVariant       = Color(0xFF282700);
  static const primary              = Color(0xFFF3FFCA);
  static const primaryContainer     = Color(0xFFCAFD00);
  static const onPrimaryContainer   = Color(0xFF4A5E00);
  static const secondary            = Color(0xFF00E3FD);
  static const onSurface            = Color(0xFFFDFAB4);
  static const onSurfaceVariant     = Color(0xFFB0AE70);
  static const outlineVariant       = Color(0xFF4B4A16);
  static const tertiary             = Color(0xFFFFEEA5);
  static const error                = Color(0xFFFF7351);
  static const errorContainer       = Color(0xFFB92902);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.background,
          primary: AppColors.primaryContainer,
          onPrimary: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSurface: AppColors.onSurface,
        ),
        useMaterial3: true,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceContainerHigh,
          contentTextStyle: const TextStyle(color: AppColors.onSurface),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
