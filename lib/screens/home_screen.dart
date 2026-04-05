import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _logout(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.onSurfaceVariant,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SET YOUR PACE',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "TODAY'S\nDASHBOARD.",
                      style: GoogleFonts.lexend(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryContainer,
                        height: 0.95,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats
            SliverToBoxAdapter(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('activities')
                    .where('userID', isEqualTo: user!.uid)
                    .where('timestamp',
                        isGreaterThanOrEqualTo:
                            Timestamp.fromDate(startOfDay))
                    .where('timestamp',
                        isLessThan: Timestamp.fromDate(endOfDay))
                    .snapshots(),
                builder: (context, snapshot) {
                  int steps = 0;
                  int calories = 0;
                  int workouts = 0;

                  if (snapshot.hasData &&
                      snapshot.data!.docs.isNotEmpty) {
                    workouts = snapshot.data!.docs.length;
                    for (var doc in snapshot.data!.docs) {
                      steps    += (doc['steps'] ?? 0) as int;
                      calories += (doc['caloriesBurned'] ?? 0) as int;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TODAY'S ACTIVITY",
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Top row — two small bento cards
                        Row(
                          children: [
                            Expanded(
                              child: _bentoSmall(
                                label: 'DAILY STEPS',
                                value: _fmt(steps),
                                accentColor: AppColors.primary,
                                icon: Icons.directions_walk_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _bentoSmall(
                                label: 'CALORIES',
                                value: _fmt(calories),
                                accentColor: AppColors.secondary,
                                icon: Icons.local_fire_department_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Wide bento card
                        _bentoWide(
                          label: 'WORKOUTS LOGGED',
                          value: '$workouts',
                          unit: 'TODAY',
                          icon: Icons.fitness_center_rounded,
                          accentColor: AppColors.tertiary,
                          empty: workouts == 0,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  Widget _bentoSmall({
    required String label,
    required String value,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Icon(icon, size: 90, color: accentColor.withOpacity(0.07)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  letterSpacing: 2,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bentoWide({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color accentColor,
    required bool empty,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.lexend(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      unit,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (empty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Log a workout to get started',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(icon, size: 52, color: accentColor.withOpacity(0.15)),
        ],
      ),
    );
  }
}
