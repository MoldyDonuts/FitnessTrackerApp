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
  static final _ctaStyle = GoogleFonts.lexend(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.onPrimaryContainer,
    letterSpacing: 1,
  );
  static final _hintStyle = GoogleFonts.manrope(
    color: Color(0x66B0AE70),
    fontSize: 15,
  );
  static final _typeActiveStyle = GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.background,
  );
  static final _typeInactiveStyle = GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurfaceVariant,
  );
  static final _emptyStyle = GoogleFonts.manrope(
    fontSize: 12,
    color: AppColors.onSurfaceVariant,
    fontStyle: FontStyle.italic,
  );

  late final Stream<QuerySnapshot> _workoutStream;
  late final String _uid;
  bool _isAuthenticated = false;
  final nameController = TextEditingController();
  final durationController = TextEditingController();
  final caloriesController = TextEditingController();
  final stepsController = TextEditingController();

  String selectedType = 'Cardio';
  static const workoutTypes = ['Cardio', 'Strength', 'Flexibility', 'Other'];

  static const Map<String, Color> _typeColors = {
    'Cardio': AppColors.secondary,
    'Strength': AppColors.primaryContainer,
    'Flexibility': AppColors.tertiary,
    'Other': AppColors.onSurfaceVariant,
  };

  @override
  void initState(){
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;

    _uid = user.uid;
    _isAuthenticated = true;

    _workoutStream = FirebaseFirestore.instance
    .collection('activities')
    .where('userID', isEqualTo: _uid)
    .orderBy('timestamp', descending: true)
    .limit(10)
    .snapshots();
  }

  Future<void> _logWorkout() async {
    final bool stepsRequired = selectedType == 'Cardio';
    if (nameController.text.isEmpty ||
        durationController.text.isEmpty ||
        caloriesController.text.isEmpty ||
        (stepsRequired && stepsController.text.isEmpty)) {
      _snack('Please fill in all fields');
      return;
    }
    final duration = int.tryParse(durationController.text.trim());
    final calories = int.tryParse(caloriesController.text.trim());
    final steps = stepsRequired ? int.tryParse(stepsController.text.trim()) : 0;

    if (duration == null || calories == null || (stepsRequired && steps == null)) {
      _snack('Duration, calories, and steps must be numbers');
      return;
    }

    if(duration <= 0 || calories <= 0 || (stepsRequired && steps! < 0)){
      _snack('Duration and calories must be greater than 0; Steps cannot be negative');
    }

    try {
      await FirebaseFirestore.instance.collection('activities').add({
        'userID': _uid,
        'workoutName': nameController.text.trim(),
        'workoutType': selectedType,
        'duration': duration,
        'caloriesBurned': calories,
        'steps': steps ?? 0,
        'timestamp': Timestamp.now(),
      });
      if(!mounted) return;
      nameController.clear();
      durationController.clear();
      caloriesController.clear();
      stepsController.clear();
      _snack('Workout logged!');
    } catch (e) {
      if(!mounted) return;
      _snack('Error logging workout: $e');
    }
  }

  Future<void> _deleteWorkout(String docID) async {
    try {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(docID)
          .delete();
      if(!mounted) return;
      _snack('Workout deleted');
    } catch (e) {
      if(!mounted) return;
      _snack('Error deleting workout: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

              // Hero
              Text('LOG YOUR', style: _heroLabelStyle),
              const SizedBox(height: 8),
              Text('WORKOUT.', style: _heroTitleStyle),
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
                        final color =
                            _typeColors[t] ?? AppColors.onSurfaceVariant;
                        return GestureDetector(
                          onTap: () => setState(() {
                            selectedType = t;
                            if (t != 'Cardio') {
                              stepsController.clear();
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? color
                                  : AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              t,
                              style: active
                                  ? _typeActiveStyle
                                  : _typeInactiveStyle,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            durationController,
                            'DURATION (MIN)',
                            '30',
                            numeric: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            caloriesController,
                            'CALORIES',
                            '200',
                            numeric: true,
                          ),
                        ),
                      ],
                    ),
                    if(selectedType == 'Cardio') ...[
                      const SizedBox(height: 16),
                      _field(stepsController, 'STEPS', '4000', numeric: true),
                      ],
                      const SizedBox(height: 24),
                    // CTA
                    GestureDetector(
                      onTap: _logWorkout,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'LOG WORKOUT',
                          textAlign: TextAlign.center,
                          style: _ctaStyle,
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
              if(!_isAuthenticated)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text('Not logged in', style: _emptyStyle,),
                  ),
                )
              else
              StreamBuilder<QuerySnapshot>(
                stream: _workoutStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          'No workouts logged yet',
                          style: _emptyStyle,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      return _WorkoutCard(
                        key: ValueKey(doc.id),
                        data: doc.data() as Map<String, dynamic>,
                        docId: doc.id,
                        onDelete: () => _deleteWorkout(doc.id),
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

  Widget _sectionLabel(String text) => Text(text, style: _sectionLabelStyle);

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
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
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
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    durationController.dispose();
    caloriesController.dispose();
    stepsController.dispose();
    super.dispose();
  }
}

class _WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final VoidCallback onDelete;

  const _WorkoutCard({
    super.key,
    required this.data,
    required this.docId,
    required this.onDelete,
  });

  static const _typeColors = {
    'Cardio': AppColors.secondary,
    'Strength': AppColors.primaryContainer,
    'Flexibility': AppColors.tertiary,
    'Other': AppColors.onSurfaceVariant,
  };

  static const _typeColorsFaded = {
    'Cardio': Color(0x1900E3FD),
    'Strength': Color(0x19CAFD00),
    'Flexibility': Color(0x19FFEEA5),
    'Other': Color(0x19B0AE70),
  };

  static final _nameStyle = GoogleFonts.lexend(
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontSize: 15,
  );

  static final _metaStyle = GoogleFonts.manrope(
    fontSize: 11,
    color: AppColors.onSurfaceVariant,
  );

  static const _timestampColor = Color(0x8CB0AE70);

  @override
  Widget build(BuildContext context) {
    final type = data['workoutType'] ?? 'Other';
    final color = _typeColors[type] ?? AppColors.onSurfaceVariant;
    final faded = _typeColorsFaded[type] ?? const Color(0x19B0AE70);
    final ts = (data['timestamp'] as Timestamp).toDate();
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
              color: faded,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.fitness_center_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['workoutName'] ?? 'Workout', style: _nameStyle),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Chip(label: type, color: color, faded: faded),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${data['duration'] ?? 0}min  •  '
                        '${data['caloriesBurned'] ?? 0}cal  •  '
                        '${data['steps'] ?? 0} steps',
                        style: _metaStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${ts.day}/${ts.month}/${ts.year}  '
                  '${ts.hour}:${ts.minute.toString().padLeft(2, '0')}',
                  style: _metaStyle.copyWith(color: _timestampColor),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.onSurfaceVariant,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color faded;

  const _Chip({required this.label, required this.color, required this.faded});

  static final _style = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: faded,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(label, style: _style.copyWith(color: color)),
    );
  }
}
