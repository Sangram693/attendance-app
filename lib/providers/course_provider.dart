import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../app_constant/api_urls.dart';

class CourseProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = false;
  String _errorMessage = "";
  String? _qrData;
  Uint8List? _qrImage;

  List<Map<String, dynamic>> get courses => _courses;
  List<Map<String, dynamic>> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get qrData => _qrData;
  Uint8List? get qrImage => _qrImage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<void> getCourses(String query) async {
    final uri = "${ApiUrls.baseUrl}${ApiUrls.getCourses}$query";
    String? token = await _storage.read(key: "token");

    if (token == null) {
      _setErrorMessage("No authorization token found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(uri),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _courses = List<Map<String, dynamic>>.from(data);
        notifyListeners();
      } else {
        _setErrorMessage("Failed to fetch courses");
      }
    } catch (e) {
      _setErrorMessage("Error fetching courses: $e");
    }
  }

  Future<void> getSubjects(String query) async {
    final uri = "${ApiUrls.baseUrl}${ApiUrls.getSubjects}$query";
    String? token = await _storage.read(key: "token");

    if (token == null) {
      _setErrorMessage("No authorization token found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(uri),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _subjects = List<Map<String, dynamic>>.from(data);
        notifyListeners();
      } else {
        _setErrorMessage("Failed to fetch subjects");
      }
    } catch (e) {
      _setErrorMessage("Error fetching subjects: $e");
    }
  }

  Future<bool> generateQR({
    required String courseId,
    required String subjectId,
    required String classId,
  }) async {
    const uri = "${ApiUrls.baseUrl}${ApiUrls.generateQr}";
    String? token = await _storage.read(key: "token");

    if (token == null) {
      _setErrorMessage("No authorization token found");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(uri),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token
        },
        body: jsonEncode({
          "courseId": courseId,
          "subjectId": subjectId,
          "classId": classId,
        }),
      );

      if (response.statusCode == 200) {
        // Check content type to determine if it's JSON or binary
        final contentType = response.headers['content-type'];
        if (contentType?.contains('application/json') == true) {
          // Handle JSON response
          final data = jsonDecode(response.body);
          _qrData = data['qrData'];
          _qrImage = null;
        } else {
          // Handle binary response
          _qrImage = response.bodyBytes;
          _qrData = base64Encode(response.bodyBytes);
        }
        notifyListeners();
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);
          _setErrorMessage(data['error'] ?? "Failed to generate QR code");
        } catch (e) {
          _setErrorMessage("Failed to generate QR code");
        }
        return false;
      }
    } catch (e) {
      _setErrorMessage("Error generating QR code: $e");
      return false;
    }
  }

  void clearQrData() {
    _qrData = null;
    _qrImage = null;
    notifyListeners();
  }
}