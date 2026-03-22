import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'workouts_screen.dart';

class HomeScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  HomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fitness Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //Welcome message
            Text(
              "Welcome, ${user?.email}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            //Daily activity
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('activities')
                  .where('userID', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error : ${snapshot.error}'),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Today's Activity",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('Steps : 0'),
                          Text('Calories : 0'),
                          SizedBox(height: 10),
                          Text(
                            'No activities logged yet. Start by logging your workout!',
                          ),
                        ],
                      ),
                    ),
                  );
                }
                int totalSteps = 0;
                int totalCalories = 0;

                for (var doc in snapshot.data!.docs) {
                  totalSteps += (doc['steps'] ?? 0) as int;
                  totalCalories += (doc['caloriesBurned'] ?? 0) as int;
                }

                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          "Today's Activity",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Steps: $totalSteps"),
                        Text("Calories: $totalCalories"),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 30),

            // Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WorkoutsScreen()),
                );
                // Navigate to workout screen
              },
              child: Text("Log Workout"),
            ),

            ElevatedButton(
              onPressed: () {
                // Navigate to goals screen
              },
              child: Text("Set Goals"),
            ),

            ElevatedButton(
              onPressed: () {
                // Navigate to progress screen
              },
              child: Text("View Progress"),
            ),
          ],
        ),
      ),
    );
  }
}
