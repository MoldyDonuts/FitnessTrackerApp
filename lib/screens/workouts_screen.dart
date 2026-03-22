import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final workOutNameController = TextEditingController();
  final durationController = TextEditingController();
  final caloriesController = TextEditingController();
  final stepsController = TextEditingController();

  String selectWorkOutType = 'Cardio';
  final List<String> workoutTypes = [
    'Cardio',
    'Strength',
    'Flexibility',
    'Other',
  ];

  Future<void> logWorkout() async {
    if (workOutNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('activities').add({
        'userID': user!.uid,
        'workoutName': workOutNameController.text.trim(),
        'workoutType': selectWorkOutType,
        'duration': int.parse(durationController.text.trim()),
        'caloriesBurned': int.parse(caloriesController.text.trim()),
        'steps': int.parse(stepsController.text.trim()),
        'timestamp': Timestamp.now(),
      });
      workOutNameController.clear();
      durationController.clear();
      caloriesController.clear();
      stepsController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Workout logged successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging workout: $e')));
    }
  }

  Future<void> deleteWorkout(String docID) async {
    try {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(docID)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Workout deleted')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Workout logged successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log workout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //workout logging form
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Workout',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: workOutNameController,
                      decoration: InputDecoration(
                        labelText: 'Workout Name *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Morning Run',
                      ),
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectWorkOutType,
                      decoration: InputDecoration(
                        labelText: 'Workout Type',
                        border: OutlineInputBorder(),
                      ),
                      items: workoutTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectWorkOutType = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      decoration: InputDecoration(
                        labelText: 'Duration (minutes) *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: caloriesController,
                      decoration: InputDecoration(
                        labelText: 'Calories Burned',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: stepsController,
                      decoration: InputDecoration(
                        labelText: 'Steps Taken',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: logWorkout,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Log Workout',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            //workout history
            Text(
              'Recent Workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activities')
                  .where('userID', isEqualTo: user!.uid)
                  .orderBy('timestamp', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No workouts logged yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var workout = snapshot.data!.docs[index];
                    var data = workout.data() as Map<String, dynamic>;
                    var timestamp = (data['timestamp'] as Timestamp).toDate();
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.fitness_center),
                        ),
                        title: Text(
                          data['workoutName'] ?? 'Workout',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${data['workoutType'] ?? 'N/A'}'),
                            Text(
                              'Duration: ${data['duration'] ?? 0} min |'
                              'Calories: ${data['caloriesBurned'] ?? 0} |'
                              'Steps: ${data['steps'] ?? 0} |',
                            ),
                            Text(
                              '${timestamp.day}/${timestamp.month}/${timestamp.year} '
                              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteWorkout(workout.id),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose(){
    workOutNameController.dispose();
    durationController.dispose();
    caloriesController.dispose();
    stepsController.dispose();
    super.dispose();
  }
}
