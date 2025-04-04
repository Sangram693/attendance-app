import 'package:aimtech/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? email;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      if (mounted) {
        final args = ModalRoute.of(context)?.settings.arguments as Map?;

        setState(() {
          email = args?['email'];
        });
      }
      provider.startTimer();
    });
  }

  void whichScreen(String screen) {
    Navigator.pushNamedAndRemoveUntil(context, screen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter OTP"),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.purple, Colors.indigo],
                ).createShader(bounds),
                child: Text(
                  "Enter the OTP sent to your email",
                  style: TextStyle(
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Keep text visible with gradient
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              // OTP Input Field using Pinput
              Pinput(
                controller: _otpController,
                length: 6, // Set the OTP length
                keyboardType: TextInputType.number,
                defaultPinTheme: PinTheme(
                  height: width * 0.1,
                  width: width * 0.1,
                  textStyle: TextStyle(
                      fontSize: width * 0.04, fontWeight: FontWeight.w600),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(width * 0.01),
                  ),
                ),
                onCompleted: (pin) {
                  debugPrint("Entered OTP: $pin");
                },
              ),
              SizedBox(height: height * 0.02),
              // Submit Button
              Consumer<UserProvider>(builder: (context, provider, child) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.01),
                      gradient: LinearGradient(
                        colors: provider.isLoading
                            ? [Colors.grey, Colors.grey]
                            : [Colors.purple, Colors.indigo],
                      )),
                  child: ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            String otp = _otpController.text;

                            if (otp.length == 6 && email != null) {
                              provider.setLoading(true);
                              bool success =
                                  await provider.verifyOtp(otp, email!);
                              provider.setLoading(false);
                              if (success) {
                                // Instead of provider.oldStudent, use the returned value from verifyOtp()
                                if (provider.isLogin) {
                                  whichScreen("/home");
                                } else {
                                  whichScreen("/signup");
                                }
                              } else {
                                // Handle invalid OTP case
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          provider.errorMessage.isNotEmpty
                                              ? provider.errorMessage
                                              : "OTP verification failed")),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Please enter a valid 6-digit OTP")),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.01),
                        ),
                        fixedSize: Size.fromWidth(width * 0.65)),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Verify OTP"),
                  ),
                );
              }),
              // SizedBox(height: height * 0.02),
              // Consumer<UserProvider>(builder: (context, provide, _) {
              //   return provide.second == 0
              //       ? InkWell(
              //           onTap: () {
              //             provide.resetTimer();
              //           },
              //           child: ShaderMask(
              //             shaderCallback: (bounds) => const LinearGradient(
              //               colors: [Colors.purple, Colors.indigo],
              //             ).createShader(bounds),
              //             child: Text(
              //               "Resend OTP",
              //               style: TextStyle(
              //                 fontSize: width * 0.03,
              //                 fontWeight: FontWeight.bold,
              //                 color: Colors
              //                     .white, // Keep text visible with gradient
              //               ),
              //             ),
              //           ),
              //         )
              //       : ShaderMask(
              //           shaderCallback: (bounds) => const LinearGradient(
              //             colors: [Colors.purple, Colors.indigo],
              //           ).createShader(bounds),
              //           child: Text(
              //             "Resend OTP in ${provide.second} second",
              //             style: TextStyle(
              //               fontSize: width * 0.03,
              //               fontWeight: FontWeight.bold,
              //               color:
              //                   Colors.white, // Keep text visible with gradient
              //             ),
              //           ),
              //         );
              // })
            ],
          ),
        ),
      ),
    );
  }
}
