import 'package:aimtech/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_update/in_app_update.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    try {
      // Check if an update is available
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      } else {
        checkLoginStatus();
      }
    } catch (e) {
      debugPrint("Error checking for updates: $e");
      checkLoginStatus();
    }
  }

  Future<void> checkLoginStatus() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    await provider.loadLoginStatus();

    if (!mounted) return;

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (provider.isLogin) {
        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.purple, Colors.indigo])
        ),
        child: const Center(
          child: Image(image: AssetImage("assets/aimtech logo.png")),
        ),
      ),
    );
  }
}
