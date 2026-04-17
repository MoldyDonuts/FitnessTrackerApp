import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  static const _stepsIconFaded = Color(0x1E00E3FD);
  static const _workoutsIconFaded = Color(0x1ECAFD00);
  static const _caloriesIconFaded = Color(0x1EFFEEA5);
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
    letterSpacing: -2,
    height: 1,
  );
  static final _sectionLabelStyle = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 2,
  );
  static final _cardTitleStyle = GoogleFonts.lexend(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static final _statStyle = GoogleFonts.lexend(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    height: 1,
  );
  static final _statUnitStyle = GoogleFonts.manrope(
    fontSize: 12,
    color: AppColors.onSurfaceVariant,
  );
  static final _achievementStyle = GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static final _emptyStyle = GoogleFonts.manrope(
    fontSize: 13,
    color: AppColors.onSurfaceVariant,
    fontStyle: FontStyle.italic,
  );

  late final String _uid;
  late final Stream<QuerySnapshot> _activityStream;
  late final Stream<DocumentSnapshot> _goalsStream;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _uid = user.uid;
    _isAuthenticated = true;

    final DateTime now = DateTime.now();
    final DateTime weekAgo = now.subtract(const Duration(days: 7));

    _activityStream = FirebaseFirestore.instance
        .collection('activities')
        .where('userID', isEqualTo: _uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .snapshots();

    _goalsStream = FirebaseFirestore.instance
        .collection('goals')
        .doc(_uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: !_isAuthenticated
            ? Center(child: Text('Not logged in', style: _emptyStyle))
            : StreamBuilder<DocumentSnapshot>(
                stream: _goalsStream,
                builder: (context, goalsSnap) {
                  if (goalsSnap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                      ),
                    );
                  }
                  final goalsData =
                      (goalsSnap.hasData && goalsSnap.data!.exists)
                      ? goalsSnap.data!.data() as Map<String, dynamic>
                      : <String, dynamic>{};

                  final int dailyStepsGoal = goalsData['dailySteps'] ?? 10000;
                  final int weeklyWorkoutsGoal =
                      goalsData['weeklyWorkouts'] ?? 5;
                  final int weeklyCaloriesGoal =
                      goalsData['weeklyCalories'] ?? 2500;

                  return StreamBuilder<QuerySnapshot>(
                    stream: _activityStream,
                    builder: (context, activitySnap) {
                      if (activitySnap.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryContainer,
                          ),
                        );
                      }
                      int totalSteps = 0;
                      int totalCalories = 0;
                      int workoutCount = 0;

                      if (activitySnap.hasData) {
                        workoutCount = activitySnap.data!.docs.length;
                        for (var doc in activitySnap.data!.docs) {
                          totalSteps += (doc['steps'] ?? 0) as int;
                          totalCalories += (doc['caloriesBurned'] ?? 0) as int;
                        }
                      }

                      final double stepsProgress =
                          (totalSteps / (dailyStepsGoal * 7)).clamp(0.0, 1.0);
                      final double workoutsProgress =
                          (workoutCount / weeklyWorkoutsGoal).clamp(0.0, 1.0);
                      final double caloriesProgress =
                          (totalCalories / weeklyCaloriesGoal).clamp(0.0, 1.0);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            Text('YOUR', style: _heroLabelStyle),
                            const SizedBox(height: 8),
                            Text('PROGRESS.', style: _heroTitleStyle),
                            const SizedBox(height: 8),
                            Text('LAST 7 DAYS', style: _sectionLabelStyle),
                            const SizedBox(height: 32),

                            _progressCard(
                              icon: Icons.directions_walk_rounded,
                              iconColor: AppColors.secondary,
                              fadedColor: _stepsIconFaded,
                              title: 'Weekly Steps',
                              current: totalSteps,
                              goal: dailyStepsGoal * 7,
                              progress: stepsProgress,
                              unit: 'steps',
                            ),
                            const SizedBox(height: 16),
                            _progressCard(
                              icon: Icons.fitness_center_rounded,
                              iconColor: AppColors.primaryContainer,
                              fadedColor: _workoutsIconFaded,
                              title: 'Weekly Workouts',
                              current: workoutCount,
                              goal: weeklyWorkoutsGoal,
                              progress: workoutsProgress,
                              unit: 'workouts',
                            ),
                            const SizedBox(height: 16),
                            _progressCard(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: AppColors.tertiary,
                              fadedColor: _caloriesIconFaded,
                              title: 'Weekly Calories',
                              current: totalCalories,
                              goal: weeklyCaloriesGoal,
                              progress: caloriesProgress,
                              unit: 'calories',
                            ),
                            const SizedBox(height: 32),

                            Text('ACHIEVEMENTS', style: _sectionLabelStyle),
                            const SizedBox(height: 16),
                            _achievementsCard(
                              stepsProgress: stepsProgress,
                              workoutsProgress: workoutsProgress,
                              caloriesProgress: caloriesProgress,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _progressCard({
    required IconData icon,
    required Color iconColor,
    required Color fadedColor,
    required String title,
    required int current,
    required int goal,
    required double progress,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: fadedColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: _cardTitleStyle),
            ],
          ),
          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$current $unit', style: _statStyle),
              Text('/ $goal', style: _statUnitStyle),
            ],
          ),

          Text(
            '${(progress * 100).toStringAsFixed(0)}% complete',
            style: _statUnitStyle,
          ),
        ],
      ),
    );
  }

  Widget _achievementsCard({
    required double stepsProgress,
    required double workoutsProgress,
    required double caloriesProgress,
  }) {
    final hasAny =
        stepsProgress >= 1.0 ||
        workoutsProgress >= 1.0 ||
        caloriesProgress >= 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: hasAny
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (stepsProgress >= 1.0)
                  _achievementRow(
                    '🏆 Steps Goal Achieved!',
                    AppColors.secondary,
                  ),
                if (workoutsProgress >= 1.0)
                  _achievementRow(
                    '💪 Workout Goal Achieved!',
                    AppColors.primaryContainer,
                  ),
                if (caloriesProgress >= 1.0)
                  _achievementRow(
                    '🔥 Calorie Goal Achieved!',
                    AppColors.tertiary,
                  ),
              ],
            )
          : Text('Keep going! Achievements coming soon.', style: _emptyStyle),
    );
  }

  Widget _achievementRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: _achievementStyle.copyWith(color: color)),
        ],
      ),
    );
  }
}
