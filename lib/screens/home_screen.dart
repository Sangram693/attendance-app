import 'package:aimtech/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? studentName;
  late Timer _timer;

  void whichScreen(String screen) {
    Navigator.pushNamed(context, screen);
  }

  void navigateLogin() {
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  void init() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final name = await userProvider.getStudentData("name");
    setState(() {
      studentName = name;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
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
        title: FittedBox(
            child: Text(
          studentName != null && studentName!.isNotEmpty
              ? "Welcome, $studentName"
              : "Welcome, User",
        )),
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.purple, Colors.indigo]),
          ),
        ),
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
              GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: width * 0.03,
                  mainAxisSpacing: width * 0.03,
                  childAspectRatio: 1.5,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(context, "Scan QR", Icons.qr_code_scanner,
                      Colors.orange, width, height, () {
                    whichScreen("/scan");
                  }),
                  _buildGridItem(context, "Attendance", Icons.history,
                      Colors.blue, width, height, () {
                    whichScreen("/attendance");
                  }),
                  _buildGridItem(context, "Profile", Icons.person, Colors.green,
                      width, height, () {
                    whichScreen("/profile");
                  }),
                  _buildGridItem(context, "Routine", Icons.schedule,
                      Colors.teal, width, height, () {
                    whichScreen("/routine");
                  }),
                  _buildGridItem(
                      context, "Quiz", Icons.quiz, Colors.pink, width, height,
                      () {
                    whichScreen("/quiz");
                  }),
                  _buildGridItem(context, "Notice", Icons.notifications_active,
                      Colors.purple, width, height, () {
                    whichScreen("/notice");
                  }),
                  _buildGridItem(context, "Exam", Icons.edit_note,
                      Colors.cyan, width, height, () {
                    whichScreen("/exam");
                  }),
                  _buildGridItem(context, "Logout", Icons.exit_to_app,
                      Colors.red, width, height, () async {
                    final bool success =
                        await Provider.of<UserProvider>(context, listen: false)
                            .logout();
                    if (success) {
                      navigateLogin();
                    }
                  }),
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

  Widget _buildGridItem(BuildContext context, String title, IconData icon,
      Color color, double width, double height, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(width * 0.02),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color]),
          borderRadius: BorderRadius.circular(width * 0.03),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: width * 0.12, color: Colors.white),
            SizedBox(height: height * 0.01),
            FittedBox(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
