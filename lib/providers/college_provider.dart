// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../app_constant/api_urls.dart';
// import '../models/college_model.dart'; // Import your model class
//
// class CollegeProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _colleges = [];
//   CollegeModel? _selectedCollege;
//   String? _errorMessage;
//
//   List<Map<String, dynamic>> get colleges => _colleges;
//   CollegeModel? get selectedCollege => _selectedCollege;
//   String? get errorMessage => _errorMessage;
//
//   void _setMessage(String msg){
//     _errorMessage = msg;
//     notifyListeners();
//   }
//
//   Future<void> getColleges(String collegeName) async {
//     final uri = "${ApiUrls.baseUrl}${ApiUrls.getColleges}$collegeName";
//     _setMessage("");
//     try {
//       var response = await http.get(Uri.parse(uri));
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         _colleges = List<Map<String, dynamic>>.from(data);
//         notifyListeners();
//       } else {
//         _setMessage("Error fetching colleges: ${response.statusCode}");
//       }
//     } catch (e) {
//       _setMessage("Error fetching college list: $e");
//     }
//   }
//
//   Future<void> getSingleCollege(String code) async {
//     final uri = "${ApiUrls.baseUrl}${ApiUrls.getCollege}$code";
//     _setMessage("");
//     try {
//       var response = await http.get(Uri.parse(uri));
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         _selectedCollege = CollegeModel.fromJson(data);
//         if(_selectedCollege == null){
//           _setMessage("error fetching college");
//         }
//         notifyListeners();
//       } else {
//         _setMessage("Error fetching college details: ${response.statusCode}");
//       }
//     } catch (e) {
//       _setMessage("Error fetching single college details: $e");
//     }
//   }
// }
