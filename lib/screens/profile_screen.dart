import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void init() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadStudentDetails();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.indigo],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.04), // Responsive padding
        child: Column(
          children: [
            Container(
              width: width,
              height: height * 0.15,
              alignment: Alignment.center,
              child: const Image(
                image: AssetImage("assets/aimtech logo.png"),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: userProvider.studentDetails.length,
                itemBuilder: (context, index) {
                  String key = userProvider.studentDetails.keys.elementAt(index);
                  String value = userProvider.studentDetails[key] ?? "N/A";

                  return Card(
                    elevation: 3,
                    color: index.isOdd ?
                    Colors.white :
                    const Color(0xffd3c9f3),
                    margin: EdgeInsets.symmetric(vertical: height * 0.007, horizontal: width * 0.02),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width * 0.03)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.02),
                      child: ListTile(
                        title: Text(
                          key,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: width * 0.04),
                        ),
                        subtitle: Text(
                          value,
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
