import '../main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
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
  static final _fieldTextStyle = GoogleFonts.manrope(
    color: AppColors.onSurface,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  static final _hintStyle = GoogleFonts.manrope(
    color: Color(0x66B0AE70),
    fontSize: 15,
  );
  static final _ctaStyle = GoogleFonts.lexend(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.onPrimaryContainer,
    letterSpacing: 1,
  );
  final user = FirebaseAuth.instance.currentUser;
  final dailyStepsController = TextEditingController();
  final weeklyWorkoutsController = TextEditingController();
  final weeklyCaloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('goals')
          .doc(user!.uid)
          .get();
      if (!mounted) return;

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          dailyStepsController.text = data['dailySteps']?.toString() ?? '';
          weeklyWorkoutsController.text =
              data['weeklyWorkouts']?.toString() ?? '';
          weeklyCaloriesController.text =
              data['weeklyCalories']?.toString() ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading goals: $e');
    }
  }

  Future<void> saveGoals() async {
    final steps = int.tryParse(dailyStepsController.text.trim());
    final workouts = int.tryParse(weeklyWorkoutsController.text.trim());
    final calories = int.tryParse(weeklyCaloriesController.text.trim());

    if (steps == null || workouts == null || calories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers for all fields'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('goals').doc(user!.uid).set({
        'dailySteps': steps,
        'weeklyWorkouts': workouts,
        'weeklyCalories': calories,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Goals saved successfully!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving goals: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Text('SET YOUR', style: _heroLabelStyle),
              const SizedBox(height: 8),
              Text('GOALS.', style: _heroTitleStyle),
              const SizedBox(height: 32),

              _goalCard(
                icon: Icons.directions_walk_rounded,
                iconColor: AppColors.secondary,
                title: 'DAILY STEPS',
                controller: dailyStepsController,
                hint: 'e.g. 10000',
              ),
              const SizedBox(height: 16),

              _goalCard(
                icon: Icons.fitness_center_rounded,
                iconColor: AppColors.primaryContainer,
                title: 'WEEKLY WORKOUTS',
                controller: weeklyWorkoutsController,
                hint: 'e.g. 5',
              ),
              const SizedBox(height: 16),

              _goalCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.tertiary,
                title: 'WEEKLY CALORIES',
                controller: weeklyCaloriesController,
                hint: 'e.g. 2500',
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: saveGoals,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    'SAVE GOALS',
                    textAlign: TextAlign.center,
                    style: _ctaStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required TextEditingController controller,
    required String hint,
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
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: _sectionLabelStyle),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: _fieldTextStyle,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: _hintStyle,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    dailyStepsController.dispose();
    weeklyCaloriesController.dispose();
    weeklyWorkoutsController.dispose();
    super.dispose();
  }
}
