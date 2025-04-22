import 'package:aimtech/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? studentName;
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
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      // backgroundColor: Colors.blue[100],
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: height * 0.02),
          child: Expanded(
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:2,
                crossAxisSpacing: width * 0.03,
                mainAxisSpacing: width * 0.03,
                childAspectRatio: 1.5, // Adjust ratio dynamically
              ),
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
          ),
        ),
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
