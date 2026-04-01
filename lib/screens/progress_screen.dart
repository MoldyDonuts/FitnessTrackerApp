import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  ProgressScreen({super.key});

  Future<Map<String, dynamic>> getWeeklyProgress() async {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(Duration(days: 7));

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('activities')
        .where('userID', isEqualTo: user!.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .get();

    int totalSteps = 0;
    int totalCalories = 0;
    int workoutCount = snapshot.docs.length;

    for (var doc in snapshot.docs) {
      totalSteps += (doc['steps'] ?? 0) as int;
      totalCalories += (doc['caloriesBurned'] ?? 0) as int;
    }

    return {
      'totalSteps': totalSteps,
      'totalCalories': totalCalories,
      'workoutCount': workoutCount,
    };
  }

  Future<Map<String, dynamic>> getGoals() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('goals')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return {'dailySteps': 10000, 'WeeklyWorkout': 5, 'weeklyCalories': 2500};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Progress')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Future.wait([getWeeklyProgress(), getGoals()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading progress'));
          }
          var progress = snapshot.data![0];
          var goals = snapshot.data![1];
          int totalSteps = progress['totalSteps'];
          int totalCalories = progress['totalCalories'];
          int workoutCount = progress['workoutCount'];
          int dailyStepsGoal = goals['dailySteps'] ?? 10000;
          int weeklyWorkoutsGoal = goals['weeklyWorkouts'] ?? 5;
          int weeklyCaloriesGoal = goals['weeklyCalories'] ?? 2500;
          double stepsProgress = (totalSteps / (dailyStepsGoal * 7)).clamp(
            0.0,
            1.0,
          );
          double workoutsProgress = (workoutCount / weeklyWorkoutsGoal).clamp(
            0.0,
            1.0,
          );
          double caloriesProgress = (totalCalories / weeklyCaloriesGoal).clamp(
            0.0,
            1.0,
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Progress',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Last 7 days', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 24),
                // Steps Progress
                _buildProgressCard(
                  context,
                  title: 'Daily Steps',
                  icon: Icons.directions_walk,
                  iconColor: Colors.blue,
                  current: totalSteps,
                  goal: dailyStepsGoal * 7,
                  progress: stepsProgress,
                  unit: 'steps',
                ),
                SizedBox(height: 16),
                // Workouts Progress
                _buildProgressCard(
                  context,
                  title: 'Weekly Workouts',
                  icon: Icons.fitness_center,
                  iconColor: Colors.orange,
                  current: workoutCount,
                  goal: weeklyWorkoutsGoal,
                  progress: workoutsProgress,
                  unit: 'workouts',
                ),
                SizedBox(height: 16),
                // Calories Progress
                _buildProgressCard(
                  context,
                  title: 'Weekly Calories',
                  icon: Icons.local_fire_department,
                  iconColor: Colors.red,
                  current: totalCalories,
                  goal: weeklyCaloriesGoal,
                  progress: caloriesProgress,
                  unit: 'calories',
                ),
                SizedBox(height: 24),
                // Recent Achievements
                Text(
                  'Achievements',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (stepsProgress >= 1.0)
                          _buildAchievement(
                            '🏆 Steps Goal Achieved!',
                            Colors.blue,
                          ),
                        if (workoutsProgress >= 1.0)
                          _buildAchievement(
                            '💪 Workout Goal Achieved!',
                            Colors.orange,
                          ),
                        if (caloriesProgress >= 1.0)
                          _buildAchievement(
                            '🔥 Calorie Goal Achieved!',
                            Colors.red,
                          ),
                        if (stepsProgress < 1.0 &&
                            workoutsProgress < 1.0 &&
                            caloriesProgress < 1.0)
                          Text(
                            'Keep going! Achievements coming soon.',
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required int current,
    required int goal,
    required double progress,
    required String unit,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievement(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: color),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
