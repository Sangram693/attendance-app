import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
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
      body: GridView.count(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.04, vertical: height * 0.02),
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