import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_constant/app_import.dart';
import 'providers/course_provider.dart';
import 'screens/not_found_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        // ChangeNotifierProvider(create: (context) => CollegeProvider()),
        ChangeNotifierProvider(create: (context) => CourseProvider()),
      ],
      child: MaterialApp(
        title: 'Aimtech',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0000ff)),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          "/": (context) => const SplashScreen(),
          "/login": (context) => const LoginScreen(),
          "/home": (context) => const HomeScreen(),
          "/teacherHome": (context) => const TeacherHomeScreen(),
          "/collegeAdmin": (context) => const CollegeAdminScreen(),
          "/generateQr": (context) => const GenerateQrScreen(),
          "/attendance": (context) => const AttendanceScreen(),
          "/profile": (context) => const ProfileScreen(),
          "/scan": (context) => const ScanQr(),
          "/quiz": (context) => const QuizScreen(),
          "/notice": (context) => const NoticeScreen(),
          "/routine": (context) => const RoutineScreen(),
          "/exam": (context) => const ExamScreen(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => const NotFoundScreen(), // <-- Your custom fallback screen
        ),
      ),
    );
  }
}

