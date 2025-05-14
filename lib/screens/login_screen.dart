import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controllerUserId = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Secure storage instance
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Load saved credentials on initialization
  }

  Future<void> _loadSavedCredentials() async {
    String? savedUserId = await _secureStorage.read(key: "savedUserId");
    String? savedPassword = await _secureStorage.read(key: "savedPassword");

    if (savedUserId != null && savedPassword != null) {
      setState(() {
        _controllerUserId.text = savedUserId;
        _controllerPassword.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  void showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black87,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _saveCredentials(String userId, String password) async {
    if (_rememberMe) {
      await _secureStorage.write(key: "savedUserId", value: userId);
      await _secureStorage.write(key: "savedPassword", value: password);
    } else {
      await _secureStorage.delete(key: "savedUserId");
      await _secureStorage.delete(key: "savedPassword");
    }
  }

  Future<void> _saveLoginStatus(bool isLoggedIn) async {
    await _secureStorage.write(key: "isLoggedIn", value: isLoggedIn ? "true" : "false");
  }

  Future<void> _handleLoginSuccess(BuildContext context, UserProvider provider) async {
    String? role = await provider.getRole();
    if (role == null) return;

    if (!context.mounted) return;

    switch (role) {
      case 'STU_CURR':
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 'USR_TCHR':
        Navigator.pushReplacementNamed(context, '/teacherHome');
        break;
      case 'COLG_ADM':
        Navigator.pushReplacementNamed(context, '/collegeAdmin');
        break;
      default:
        showMessage("Unknown user role", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final style = TextStyle(fontWeight: FontWeight.w400, fontSize: height * 0.025);
    final decoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
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
                        Text("User ID", style: style),
                        Text("*", style: style.copyWith(color: Colors.red)),
                      ],
                    ),
                    TextFormField(
                      controller: _controllerUserId,
                      decoration: decoration.copyWith(
                        prefixIcon: const Icon(Icons.person),
                        hintText: "Enter your user ID"
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your user ID";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.03),
                    
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Password", style: style),
                        Text("*", style: style.copyWith(color: Colors.red)),
                      ],
                    ),
                    TextFormField(
                      controller: _controllerPassword,
                      obscureText: !_isPasswordVisible, // Use the state variable to toggle visibility
                      decoration: decoration.copyWith(
                        prefixIcon: const Icon(Icons.lock),
                        hintText: "Enter your password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.03),

                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        Text("Remember Me", style: style),
                      ],
                    ),
                    SizedBox(height: height * 0.03),

                    Consumer<UserProvider>(
                      builder: (context, provider, child) {
                        return Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: provider.isLoading
                                ? [Colors.grey, Colors.grey]
                                : [Colors.purple, Colors.indigo]
                            ),
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                          child: InkWell(
                            onTap: provider.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    provider.setLoading(true);
                                    final bool success = await provider.login(
                                      userId: _controllerUserId.text,
                                      password: _controllerPassword.text,
                                    );
                                    provider.setLoading(false);

                                    if (success) {
                                      await _saveCredentials(
                                        _controllerUserId.text,
                                        _controllerPassword.text,
                                      );
                                      await _saveLoginStatus(true); // Save login status
                                      await _handleLoginSuccess(context, provider);
                                    } else {
                                      showMessage(
                                        provider.errorMessage.isNotEmpty
                                          ? provider.errorMessage
                                          : "Login failed",
                                        Colors.red
                                      );
                                    }
                                  }
                                },
                            borderRadius: BorderRadius.circular(width * 0.02),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: height * 0.015),
                              width: double.infinity,
                              child: provider.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: height * 0.025,
                                      color: Colors.white
                                    )
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: height * 0.2,
            width: width,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: height * 0.05),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.purple, Colors.indigo]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(width * 0.5))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: height * 0.04,
                    fontWeight: FontWeight.w400,
                    color: Colors.white
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
