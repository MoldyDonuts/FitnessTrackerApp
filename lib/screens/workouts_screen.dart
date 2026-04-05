import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final nameController     = TextEditingController();
  final durationController = TextEditingController();
  final caloriesController = TextEditingController();
  final stepsController    = TextEditingController();

  String selectedType = 'Cardio';
  static const workoutTypes = ['Cardio', 'Strength', 'Flexibility', 'Other'];

  static const Map<String, Color> _typeColors = {
    'Cardio':      AppColors.secondary,
    'Strength':    AppColors.primaryContainer,
    'Flexibility': AppColors.tertiary,
    'Other':       AppColors.onSurfaceVariant,
  };

  Future<void> _logWorkout() async {
    if (nameController.text.isEmpty ||
        durationController.text.isEmpty ||
        caloriesController.text.isEmpty ||
        stepsController.text.isEmpty) {
      _snack('Please fill in all fields');
      return;
    }
    final duration = int.tryParse(durationController.text.trim());
    final calories = int.tryParse(caloriesController.text.trim());
    final steps    = int.tryParse(stepsController.text.trim());
    if (duration == null || calories == null || steps == null) {
      _snack('Duration, calories, and steps must be numbers');
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('activities').add({
        'userID':         user!.uid,
        'workoutName':    nameController.text.trim(),
        'workoutType':    selectedType,
        'duration':       duration,
        'caloriesBurned': calories,
        'steps':          steps,
        'timestamp':      Timestamp.now(),
      });
      nameController.clear();
      durationController.clear();
      caloriesController.clear();
      stepsController.clear();
      _snack('Workout logged!');
    } catch (e) {
      _snack('Error logging workout: $e');
    }
  }

  Future<void> _deleteWorkout(String docID) async {
    try {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(docID)
          .delete();
      _snack('Workout deleted');
    } catch (e) {
      _snack('Error deleting workout: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(24, 20, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Hero
              Text(
                'LOG YOUR',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'WORKOUT.',
                style: GoogleFonts.lexend(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryContainer,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(height: 32),

              // Form card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('ADD NEW WORKOUT'),
                    const SizedBox(height: 20),
                    _field(nameController, 'WORKOUT NAME', 'e.g., Morning Run'),
                    const SizedBox(height: 16),

                    // Type chips
                    _sectionLabel('TYPE'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: workoutTypes.map((t) {
                        final active = selectedType == t;
                        final color = _typeColors[t] ?? AppColors.onSurfaceVariant;
                        return GestureDetector(
                          onTap: () => setState(() => selectedType = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: active
                                  ? color
                                  : AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              t,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? (t == 'Strength'
                                        ? AppColors.onPrimaryContainer
                                        : AppColors.background)
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: _field(durationController, 'DURATION (MIN)', '30', numeric: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(caloriesController, 'CALORIES', '200', numeric: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _field(stepsController, 'STEPS', '4000', numeric: true),
                    const SizedBox(height: 24),

                    // CTA
                    GestureDetector(
                      onTap: _logWorkout,
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'LOG WORKOUT',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onPrimaryContainer,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Recent workouts
              _sectionLabel('RECENT WORKOUTS'),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('activities')
                    .where('userID', isEqualTo: user!.uid)
                    .orderBy('timestamp', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryContainer),
                    );
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          'No workouts logged yet',
                          style: GoogleFonts.manrope(
                            color: AppColors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final ts = (data['timestamp'] as Timestamp).toDate();
                      final type = data['workoutType'] ?? 'Other';
                      final color = _typeColors[type] ?? AppColors.onSurfaceVariant;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.fitness_center_rounded,
                                  color: color, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['workoutName'] ?? 'Workout',
                                    style: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _chip(type, color),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '${data['duration'] ?? 0}min  •  '
                                          '${data['caloriesBurned'] ?? 0}cal  •  '
                                          '${data['steps'] ?? 0} steps',
                                          style: GoogleFonts.manrope(
                                            fontSize: 11,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${ts.day}/${ts.month}/${ts.year}  '
                                    '${ts.hour}:${ts.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant
                                          .withOpacity(0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18),
                              color: AppColors.onSurfaceVariant,
                              onPressed: () => _deleteWorkout(doc.id),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 2,
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool numeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            keyboardType:
                numeric ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.manrope(
              color: AppColors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.manrope(
                color: AppColors.onSurfaceVariant.withOpacity(0.4),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      );

  @override
  void dispose() {
    nameController.dispose();
    durationController.dispose();
    caloriesController.dispose();
    stepsController.dispose();
    super.dispose();
  }
}
