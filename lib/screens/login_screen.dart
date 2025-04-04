import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controllerEmail = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black87, // Better contrast for readability
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final style =
        TextStyle(fontWeight: FontWeight.w400, fontSize: height * 0.025);

    final decoration = InputDecoration(
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
      isDense: true,
      contentPadding: EdgeInsets.all(height * 0.01),
    );

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            left: width * 0.1, right: width * 0.1, bottom: height * 0.01),
        child: const Text(
          "© Copyright 2025. All Rights Reserved by \nConglomerate Business Solutions Pvt. Ltd.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: height,
            width: width,
            padding: EdgeInsets.only(
                top: height * 0.22, left: width * 0.1, right: width * 0.1),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Container(
                      width: width,
                      height: height * 0.2,
                      alignment: Alignment.center,
                      child: const Image(
                        image: AssetImage("assets/aimtech logo.png"),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Email", style: style),
                        Text("*", style: style.copyWith(color: Colors.red)),
                      ],
                    ),
                    // Email Field
                    TextFormField(
                      controller: _controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: decoration.copyWith(
                          prefixIcon: const Icon(Icons.mail),
                          hintText: "Enter your email"),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.03),

                    // Gradient Button (Fixed)
                    Consumer<UserProvider>(
                      builder: (context, provider, child) {
                        return Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: provider.isLoading
                                    ? [Colors.grey, Colors.grey]
                                    : [Colors.purple, Colors.indigo]),
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.02),
                          ),
                          child: InkWell(
                            onTap: provider.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      provider.setLoading(
                                          true); // Ensure you have a method to update isLoading
                                      final bool success = await provider
                                          .sendOtp(_controllerEmail.text);
                                      provider.setLoading(false);

                                      if (success) {
                                        otpScreen();
                                      } else {
                                        showMessage("OTP not sent", Colors.red);
                                      }
                                    }
                                  },
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      0.015),
                              width: double.infinity,
                              child: provider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text("Send OTP",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.025,
                                          color: Colors.white)),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          // Top Banner
          Container(
            height: height * 0.2,
            width: width,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: height * 0.05),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.indigo]),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(width * 0.5))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(
                      fontSize: height * 0.04,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void otpScreen() {
    Navigator.pushNamed(context, "/otp",
        arguments: {"email": _controllerEmail.text});
  }
}
