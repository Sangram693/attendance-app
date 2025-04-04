import 'package:flutter/material.dart';

class RoutineScreen extends StatefulWidget{
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Routine"),
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