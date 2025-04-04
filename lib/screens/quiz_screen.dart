import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget{
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
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