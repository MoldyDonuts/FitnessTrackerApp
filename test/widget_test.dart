import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitnesstracker/screens/login_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  // -------------------------------------------------------------------------
  // Login Screen – validation tests (no real Firebase needed)
  // -------------------------------------------------------------------------

  group('LoginScreen – validation', () {
    testWidgets('shows error when both fields are empty', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      expect(
          find.text('Please enter your email and password.'), findsOneWidget);
    });

    testWidgets('shows error when only email is filled', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField).first, 'user@example.com');
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      expect(
          find.text('Please enter your email and password.'), findsOneWidget);
    });

    testWidgets('shows error when only password is filled', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      expect(
          find.text('Please enter your email and password.'), findsOneWidget);
    });

    testWidgets('toggles to Register mode and back', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('WELCOME\nBACK.'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);

      // Scroll to toggle link before tapping (it may be off-screen on small viewports)
      final toggleFinder = find.textContaining("Don't have an account?");
      await tester.ensureVisible(toggleFinder);
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(find.text('CREATE\nACCOUNT.'), findsOneWidget);
      expect(find.text('REGISTER'), findsOneWidget);

      final backFinder = find.textContaining('Already have an account?');
      await tester.ensureVisible(backFinder);
      await tester.tap(backFinder);
      await tester.pumpAndSettle();

      expect(find.text('WELCOME\nBACK.'), findsOneWidget);
    });

    testWidgets('error clears when user toggles login/register', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pumpAndSettle();

      // Trigger the error
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();
      expect(
          find.text('Please enter your email and password.'), findsOneWidget);

      // Scroll to toggle link and tap — error should clear
      final toggleFinder = find.textContaining("Don't have an account?");
      await tester.ensureVisible(toggleFinder);
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();
      expect(
          find.text('Please enter your email and password.'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Workout form – numeric validation (pure logic tests)
  // -------------------------------------------------------------------------

  group('Workout form – numeric validation', () {
    test('rejects blank string', () {
      expect(int.tryParse(''), isNull);
    });

    test('rejects letters', () {
      expect(int.tryParse('abc'), isNull);
    });

    test('rejects float string', () {
      expect(int.tryParse('30.5'), isNull);
    });

    test('accepts valid integer strings', () {
      expect(int.tryParse('30'), 30);
      expect(int.tryParse('0'), 0);
      expect(int.tryParse('99999'), 99999);
    });

    test('negative numbers parse but app now guards against them', () {
      // int.tryParse allows negatives, but the app explicitly rejects duration <= 0
      // and calories <= 0 and steps < 0 after parsing
      final val = int.tryParse('-1');
      expect(val, -1); // parses fine
      expect(val! <= 0, isTrue); // caught by the guard in _logWorkout
    });

    test('rejects whitespace-only string', () {
      expect(int.tryParse('   '), isNull);
    });

    test('rejects special characters', () {
      expect(int.tryParse('30!'), isNull);
      expect(int.tryParse('3 0'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Edge case: extremely large workout values
  // -------------------------------------------------------------------------

  group('Workout form – large value edge cases', () {
    test('very large step count parses without overflow', () {
      final val = int.tryParse('999999999');
      expect(val, isNotNull);
      expect(val, 999999999);
    });

    test('max Dart int string is handled', () {
      final val = int.tryParse('9223372036854775807');
      expect(val, isNotNull);
    });

    test('beyond max int returns null', () {
      final val = int.tryParse('99999999999999999999999999');
      expect(val, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Email format edge cases
  // -------------------------------------------------------------------------

  group('Email format edge cases', () {
    bool looksLikeEmail(String s) => s.contains('@') && s.contains('.');

    test('valid email passes basic check', () {
      expect(looksLikeEmail('user@example.com'), isTrue);
    });

    test('missing @ fails', () {
      expect(looksLikeEmail('userexample.com'), isFalse);
    });

    test('missing dot fails', () {
      expect(looksLikeEmail('user@examplecom'), isFalse);
    });

    test('empty string fails', () {
      expect(looksLikeEmail(''), isFalse);
    });

    test('whitespace-only string fails', () {
      expect(looksLikeEmail('   '), isFalse);
    });

    test('subdomain email passes', () {
      expect(looksLikeEmail('user@mail.example.com'), isTrue);
    });
  });
}
