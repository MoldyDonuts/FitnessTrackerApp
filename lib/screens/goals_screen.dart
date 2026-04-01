import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final dailyStepsController = TextEditingController();
  final weeklyWorkoutsController = TextEditingController();
  final weeklyCaloriesController = TextEditingController();

  @override
  void initState(){
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async{
    try{
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('goals')
          .doc(user!.uid)
          .get();

      if(doc.exists){
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          dailyStepsController.text = data['dailySteps']?.toString() ?? '';
          weeklyWorkoutsController.text = data['weeklyWorkouts']?.toString() ?? '';
          weeklyCaloriesController.text = data['weeklyCalories']?.toString() ?? '';
        });
      }
    } catch (e){
      print('Error loading goals: $e');
    }
  }

  Future<void> saveGoals() async{
    try {
      await FirebaseFirestore.instance.collection('goals').doc(user!.uid).set({
        'dailySteps': int.parse(dailyStepsController.text.trim()),
        'weeklyWorkouts': int.parse(weeklyWorkoutsController.text.trim()),
        'weeklyCalories': int.parse(weeklyCaloriesController.text.trim()),
        'updatedAt': Timestamp.now(),
      },
          SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Goals saved successfully!')),
      );
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving goals: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Goals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set Your Fitness Goals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Track your progress by setting achieveable goals',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height:24),
            Card(
              elevation: 4,
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_walk, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Daily Steps Goal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: dailyStepsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Target Steps per Day',
                        border: OutlineInputBorder(),
                        hintText: 'e.g.,10000',
                        suffixIcon: Icon(Icons.flag),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fitness_center, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Weekly Workout Goals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: weeklyWorkoutsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Target Workouts per Week',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 5',
                        suffixIcon: Icon(Icons.flag),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Weekly Workout Goals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: weeklyCaloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Target Calories Burned per Week',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 2500',
                        suffixIcon: Icon(Icons.flag),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height:24),
            ElevatedButton(
                onPressed: saveGoals,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Save Goals',
                  style: TextStyle(fontSize: 18),
                ),
            ),
          ],
        ),
      ),
    );
  }
    @override
    void dispose(){
      dailyStepsController.dispose();
      weeklyCaloriesController.dispose();
      weeklyWorkoutsController.dispose();
      super.dispose();
    }

}


