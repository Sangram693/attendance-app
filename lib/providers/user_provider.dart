import 'dart:async';
import 'dart:convert';
import 'package:aimtech/app_constant/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLogin = false;
  bool _isLoading = false;
  int _second = 60;
  bool _oldStudent = false;
  String _errorMessage = "";
  String _successMessage = "";
  Map<String, String> _studentDetails = {};

  Map<String, String> get studentDetails => _studentDetails;
  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;
  int get second => _second;
  bool get oldStudent => _oldStudent;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;


  void _setSuccessMessage(String msg) {
    _successMessage = msg;
    notifyListeners();
  }

  void _setErrorMessage(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadStudentDetails() async {
    _studentDetails = {
      "Name": await _storage.read(key: "name") ?? "N/A",
      "Email": await _storage.read(key: "email") ?? "N/A",
      "Student ID": await _storage.read(key: "studentId") ?? "N/A",
      "Phone": await _storage.read(key: "phone") ?? "N/A",
      "Address": await _storage.read(key: "address") ?? "N/A",
      "College Code": await _storage.read(key: "collegeCode") ?? "N/A",
      "College Name": await _storage.read(key: "collegeName") ?? "N/A",
      "Stream Name": await _storage.read(key: "streamName") ?? "N/A",
      "Department Name": await _storage.read(key: "departmentName") ?? "N/A",
      "Semester Name": await _storage.read(key: "semName") ?? "N/A",
    };
    notifyListeners();
  }

  // Save login status and token securely
  Future<void> _saveLoginStatus(String token, bool oldStudent) async {
    await _storage.write(key: "token", value: token);
    await _storage.write(key: "oldStudent", value: oldStudent.toString());

    _isLogin = oldStudent; // Set login status based on oldStudent
    _oldStudent = oldStudent;
    notifyListeners();
  }

  Future<void> _saveStudentData(
    String name,
    String email,
    String studentId,
    String phone,
    String address,
    String collegeCode,
    String collegeName,
    String streamName,
    String departmentName,
    String semName,
    String deviceId,
  ) async {
    try {
      await _storage.write(key: "name", value: name);
      await _storage.write(key: "email", value: email);
      await _storage.write(key: "studentId", value: studentId);
      await _storage.write(key: "phone", value: phone);
      await _storage.write(key: "address", value: address);
      await _storage.write(key: "collegeCode", value: collegeCode);
      await _storage.write(key: "collegeName", value: collegeName);
      await _storage.write(key: "streamName", value: streamName);
      await _storage.write(key: "departmentName", value: departmentName);
      await _storage.write(key: "semName", value: semName);
      await _storage.write(key: "deviceId", value: deviceId);
    } catch (e) {
      throw Exception("Error saving student data: $e");
    }
  }

  Future<String?> getStudentData(String key) async {
    return await _storage.read(key: key);
  }

  // Load login status and token from storage
  Future<void> loadLoginStatus() async {
    String? token = await _storage.read(key: "token");
    String? oldStudentValue = await _storage.read(key: "oldStudent");

    if (token != null && oldStudentValue != null) {
      _isLogin = oldStudentValue == "true";
      _oldStudent = oldStudentValue == "true";
    } else {
      _isLogin = false;
      _oldStudent = false;
    }

    notifyListeners();
  }

  // Send OTP API Call
  Future<bool> sendOtp(String email) async {
    const uri = "${ApiUrls.baseUrl}${ApiUrls.sendOtp}";
    final response = await http.post(Uri.parse(uri), body: {"email": email});
    return response.statusCode == 200;
  }

  // Verify OTP and store token if successful
  Future<bool> verifyOtp(String otp, String email) async {
    const uri = "${ApiUrls.baseUrl}${ApiUrls.verifyOtp}";

    try {
      final response = await http.post(
        Uri.parse(uri),
        body: {
          "email": email,
          "otp": otp,
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['message'] == "OTP verified successfully") {
          String token = responseData['token'];
          bool oldStudent = responseData['oldStudent'];
          // Save token and login status securely
          await _saveLoginStatus(token, oldStudent);
          _setSuccessMessage(responseData['message']);
          return true;
        }
      } else {
        if (responseData.containsKey('error')) {
          _setErrorMessage(responseData['error']);
        } else {
          _setErrorMessage("Something went wrong");
        }
      }
    } catch (e) {
      _setErrorMessage("Failed to connect to the server");
    }
    return false;
  }

  // Start OTP resend timer
  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_second > 0) {
        _second--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  // Reset OTP timer
  void resetTimer() {
    _second = 60;
    startTimer();
    notifyListeners();
  }

  Future<void> register(
      String name,
      String studentId,
      String phone,
      String address,
      String collegeCode,
      String streamName,
      String departmentName,
      String semName,
      String deviceId) async {
    _setSuccessMessage("");
    _setErrorMessage("");
    String? token = await _storage.read(key: "token");
    if (token == null) {
      _setErrorMessage("Error: access denied: no token provided");
      return;
    }
    const String uri = "${ApiUrls.baseUrl}${ApiUrls.register}";

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Student-Authorization": token
    };
    final Map<String, String> body = {
      "name": name,
      "studentId": studentId,
      "phone": phone,
      "address": address,
      "college_code": collegeCode,
      "stream_name": streamName,
      "department_name": departmentName,
      "sem_name": semName,
      "device_id": deviceId
    };

    try {
      final response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _setSuccessMessage("Success: ${data['message']}");
        // Extract student details from the response
        final studentDetails = data['studentDetails'];
        if (data.containsKey('studentDetails')) {
        } else {}

        await _saveStudentData(
          studentDetails["name"],
          studentDetails["email"],
          studentDetails["studentId"],
          studentDetails["phone"].toString(),
          studentDetails["address"],
          studentDetails["college_code"],
          studentDetails["college_name"],
          studentDetails["stream_name"],
          studentDetails["department_name"],
          studentDetails["sem_name"],
          studentDetails["device_id"],
        );
        await _storage.write(key: "oldStudent", value: "true");
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        _setErrorMessage("Error: ${data['error']}");
      } else if (response.statusCode == 401) {
        _setErrorMessage("Error: access denied: no token provided");
      } else if (response.statusCode == 500) {
        _setErrorMessage("Error: internal server error");
      } else {
        _setErrorMessage(
            "Error: Unexpected status code ${response.statusCode}");
      }
    } catch (e) {
      _setErrorMessage("Error: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<bool> giveAttendance(double latitude, double longitude, String classId,
      String deviceId) async {
    const String uri = "${ApiUrls.baseUrl}${ApiUrls.giveAttendance}";
    _setSuccessMessage("");
    _setErrorMessage("");
    String? token = await _storage.read(key: "token");
    if (token == null) {
      _setErrorMessage("Error: access denied: no token provided");
      return false;
    }
    final headers = {
      "Content-Type": "application/json",
      "Student-Authorization": token
    };
    final body = jsonEncode({
      "classId": classId,
      "deviceId": deviceId,
      "latitude": latitude,
      "longitude": longitude,
    });

    try {
      var response =
          await http.post(Uri.parse(uri), headers: headers, body: body);
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _setSuccessMessage(jsonResponse['message']);
        return true;
      } else {
        _setErrorMessage(jsonResponse['error']);
      }
    } catch (e) {
      _setErrorMessage("Error: $e");
    }
    return false;
  }

  // Logout and clear stored data
  Future<bool> logout() async {
    await _saveLoginStatus("", false);
    _isLogin = false;
    _oldStudent = false;
    notifyListeners();
    return true;
  }
}
