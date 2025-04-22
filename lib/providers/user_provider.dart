import 'dart:async';
import 'dart:convert';
import 'package:aimtech/app_constant/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:advertising_id/advertising_id.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLogin = false;
  bool _isLoading = false;
  // int _second = 60;
  bool _oldStudent = false;
  String _errorMessage = "";
  String _successMessage = "";
  // Map<String, String> _studentDetails = {};

  // Map<String, String> get studentDetails => _studentDetails;
  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;
  // int get second => _second;
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


  // Save login status and token securely
  Future<void> _saveLoginStatus(String token, bool oldStudent, String role, {String? collegeId}) async {
    await _storage.write(key: "token", value: token);
    await _storage.write(key: "oldStudent", value: oldStudent.toString());
    await _storage.write(key: "role", value: role);
    if (collegeId != null) {
      await _storage.write(key: "collegeId", value: collegeId);
    }

    _isLogin = oldStudent;
    _oldStudent = oldStudent;
    notifyListeners();
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

  Future<bool> login({required String userId, required String password}) async {
    const uri = "${ApiUrls.baseUrl}${ApiUrls.login}";
    try {
      String deviceId = await _getDeviceId();
      
      final response = await http.post(
        Uri.parse(uri),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "password": password,
          "deviceId": deviceId,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData.containsKey('token')) {
          String token = responseData['token'];
          String role = responseData['role'] ?? '';
          String? collegeId = responseData['collegeId'];
          
          bool isStudent = role == 'STU_CURR';
          // Save both device ID and user ID
          await _storage.write(key: "deviceId", value: deviceId);
          await _storage.write(key: "userId", value: userId);
          await _saveLoginStatus(token, isStudent, role, collegeId: collegeId);
          _setSuccessMessage("Login successful");
          return true;
        }
      } else if (response.statusCode == 401) {
        _setErrorMessage("Invalid username or password");
      } else {
        _setErrorMessage(responseData['error'] ?? "Login failed. Please try again");
      }
    } catch (e) {
      _setErrorMessage("Failed to connect to the server. Please check your internet connection");
    }
    return false;
  }

  Future<String> _getDeviceId() async {
    try {
      String? advertisingId = await AdvertisingId.id(true); // true means limit tracking is checked
      return advertisingId ?? DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      // Fallback to timestamp-based ID if advertising ID is not available
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  Future<bool> giveAttendance(
      double latitude, double longitude, String qrData, String deviceId) async {
    try {
      Map<String, dynamic> attendanceData = jsonDecode(qrData);
      String? userId = await _storage.read(key: "userId");
      
      if (userId == null) {
        _errorMessage = 'User not authorized';
        return false;
      }
      final body = {
        'attUserId': userId,
        'attCourseId': attendanceData['courseId'],
        'attSubjectId': attendanceData['subjectId'],
        'attClassId': attendanceData['classId'],
        'attLat': latitude.toString(),
        'attLong': longitude.toString(),
        'attTs': DateTime.now().toUtc().toIso8601String(),
        'attValid': true,
        'attValidDesc': 'GPS matched',
        'attDeviceId': deviceId
      };

      final response = await http.post(
        Uri.parse("${ApiUrls.baseUrl}${ApiUrls.giveAttendance}"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _successMessage = data['message'] ?? 'Attendance marked successfully';
        return true;
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Failed to mark attendance';
        print("Sending body: $body\nStatus code: ${response.statusCode}, Response:${response.body}");
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      return false;
    }
  }

  // Logout and clear stored data
  Future<bool> logout() async {
    await _saveLoginStatus("", false, "");
    _isLogin = false;
    _oldStudent = false;
    notifyListeners();
    return true;
  }

  Future<String?> getRole() async {
    return await _storage.read(key: "role");
  }

  Future<String?> getCollegeId() async {
    return await _storage.read(key: "collegeId");
  }
}
