import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final _heroLabelStyle = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    letterSpacing: 3,
  );
  static final _heroTitleStyle = GoogleFonts.lexend(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryContainer,
    height: 0.95,
    letterSpacing: -2,
  );
  static final _emailStyle = GoogleFonts.manrope(
    fontSize: 13,
    color: AppColors.onSurfaceVariant,
    fontWeight: FontWeight.w500,
  );
  static final _sectionLabelStyle = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 2,
  );
  static final _bentoLabelStyle = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );
  static final _bentoValueStyle = GoogleFonts.lexend(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    height: 1,
  );
  static final _bentoLargeValueStyle = GoogleFonts.lexend(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    height: 1,
  );
  static final _bentoUnitStyle = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );
  static final _emptyStyle = GoogleFonts.manrope(
    fontSize: 12,
    color: AppColors.onSurfaceVariant,
    fontStyle: FontStyle.italic,
  );
  static const _stepsIconColor = Color(0x12F3FFCA);
  static const _caloriesIconColor = Color(0x1200E3FD);
  static const _workoutsIconColor = Color(0x26FFEEA5);

  late final String _uid;
  late final Timestamp _startOfDay;
  late final Timestamp _endOfDay;
  late final String _email;
  late final Stream<QuerySnapshot> _activityStream;

  ///Initializes the authenticated use UID, email, and firestore stream for today's activity data
  ///timestamps are computed once here to prevent stream re-subscription on rebuild
  ///requirements" 2.0.0, 2.1.0, 2.2.0, 2.3.0

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _uid = user.uid;
    _email = user.email ?? '';
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    _startOfDay = Timestamp.fromDate(start);
    _endOfDay = Timestamp.fromDate(start.add(const Duration(days: 1)));

    _activityStream = FirebaseFirestore.instance
    .collection('activities')
    .where('userID', isEqualTo: _uid)
    .where('timestamp', isGreaterThanOrEqualTo: _startOfDay)
    .where('timestamp', isLessThan: _endOfDay)
    .snapshots();
  }
  ///signs the current user out of firebase auth and navigates back to [LoginScreen]
  ///requirements: 1.5.0

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Log out?',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Log out',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      onTap: _logout,
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
                      style: _heroLabelStyle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "TODAY'S\nDASHBOARD.",
                      style: _heroTitleStyle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _email,
                      style: _emailStyle,
                    ),
                  ],
                ),
              ),
            ),

            // Stats
            SliverToBoxAdapter(
              child: StreamBuilder(
                stream: _activityStream,
                builder: (context, snapshot) {
                  int steps = 0;
                  int calories = 0;
                  int workouts = 0;

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    workouts = snapshot.data!.docs.length;
                    for (var doc in snapshot.data!.docs) {
                      steps += (doc['steps'] ?? 0) as int;
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
                          style: _sectionLabelStyle,
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
                                fadedColor: _stepsIconColor,
                                icon: Icons.directions_walk_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _bentoSmall(
                                label: 'CALORIES',
                                value: _fmt(calories),
                                accentColor: AppColors.secondary,
                                fadedColor: _caloriesIconColor,
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
                          fadedColor: _workoutsIconColor,
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

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  Widget _bentoSmall({
    required String label,
    required String value,
    required Color accentColor,
    required Color fadedColor,
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
            child: Icon(icon, size: 90, color: fadedColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: _bentoLabelStyle.copyWith(color: accentColor),
              ),
              Text(
                value,
                style: _bentoValueStyle,
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
    required Color fadedColor,
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
                  style: _bentoLabelStyle,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: _bentoLargeValueStyle,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      unit,
                      style: _bentoUnitStyle,
                    ),
                  ],
                ),
                if (empty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Log a workout to get started',
                      style: _emptyStyle,
                    ),
                  ),
              ],
            ),
          ),
          Icon(icon, size: 52, color: fadedColor),
        ],
      ),
    );
  }
}
