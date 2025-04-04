import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget{
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: const Text("My Attendance"),
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.purple, Colors.indigo]),
          ),
        ),
      ),
      body: const Center(
        child: Text("Currently not available",
          style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.red),),
      ),
    );
  }

}