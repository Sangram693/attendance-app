import 'package:flutter/material.dart';

class NoticeScreen extends StatefulWidget{
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text("Notices"),
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