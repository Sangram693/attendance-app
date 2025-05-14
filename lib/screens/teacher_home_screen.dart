import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/user_provider.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  _TeacherHomeScreenState createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    final DateTime now = DateTime.now();

    // Mock data for daily routine with time ranges
    final List<Map<String, dynamic>> dailyRoutine = [
      {"time": "4:55 PM - 5:00 PM", "subject": "Mathematics", "start": DateTime(now.year, now.month, now.day, 16, 55), "end": DateTime(now.year, now.month, now.day, 17, 0)},
      {"time": "5:00 PM - 5:05 PM", "subject": "Physics", "start": DateTime(now.year, now.month, now.day, 17, 0), "end": DateTime(now.year, now.month, now.day, 17, 5)},
      {"time": "5:05 PM - 5:10 PM", "subject": "Chemistry", "start": DateTime(now.year, now.month, now.day, 17, 5), "end": DateTime(now.year, now.month, now.day, 17, 10)},
    ];

    // Determine completed, ongoing, and upcoming classes
    final completedClasses = dailyRoutine.where((classInfo) => now.isAfter(classInfo["end"])).toList();
    final ongoingClass = dailyRoutine.firstWhere(
      (classInfo) => now.isAfter(classInfo["start"]) && now.isBefore(classInfo["end"]),
      orElse: () => {"subject": "None"},
    );
    final upcomingClasses = dailyRoutine.where((classInfo) => now.isBefore(classInfo["start"])).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.indigo],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final provider = Provider.of<UserProvider>(context, listen: false);
              await provider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completed, Ongoing, Upcoming Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusCard("Completed", completedClasses.isNotEmpty ? completedClasses.last["subject"] : "None", Colors.grey),
                  _buildStatusCard("Ongoing", ongoingClass["subject"], Colors.green),
                  _buildStatusCard("Upcoming", upcomingClasses.isNotEmpty ? upcomingClasses.first["subject"] : "None", Colors.orange),
                ],
              ),

              SizedBox(height: height * 0.02),

              // Daily Routine Section
              _buildSectionHeader("Daily Routine"),
              ...dailyRoutine.map((classInfo) => _buildRoutineCard(classInfo)).toList(),

              SizedBox(height: height * 0.02),

              // Existing Grid Menu
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: width * 0.03,
                mainAxisSpacing: width * 0.03,
                childAspectRatio: 1.5,
                children: [
                  _buildMenuCard(
                    context,
                    'Generate QR',
                    const Color(0xffF25022),
                    Icons.qr_code,
                    () => Navigator.pushNamed(context, '/generateQr'),
                  ),
                  _buildMenuCard(
                    context,
                    'View Attendance',
                    const Color(0xff7FBA00),
                    Icons.list_alt,
                    () => Navigator.pushNamed(context, '/attendance'),
                  ),
                  _buildMenuCard(
                    context,
                    'Profile',
                    const Color(0xff00A4EF),
                    Icons.person,
                    () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _buildMenuCard(
                    context,
                    'Notice Board',
                    const Color(0xffFFB900),
                    Icons.notifications,
                    () => Navigator.pushNamed(context, '/notice'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String className, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                className,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildRoutineCard(Map<String, dynamic> classInfo) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(
          classInfo["subject"]!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(classInfo["time"]!),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}