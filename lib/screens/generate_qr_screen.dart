import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({Key? key}) : super(key: key);

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCourseId;
  String? _selectedSubjectId;
  final TextEditingController _classIdController = TextEditingController();
  TextEditingController _courseController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  bool _showQR = false;

  void _resetForm() {
    setState(() {
      _showQR = false;
      _selectedCourseId = null;
      _selectedSubjectId = null;
      _classIdController.clear();
      _courseController.clear();
      _subjectController.clear();
    });
    Provider.of<CourseProvider>(context, listen: false).clearQrData();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.indigo],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Consumer<CourseProvider>(
          builder: (context, provider, child) {
            if (provider.qrData != null || provider.qrImage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(width * 0.04),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.02),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Course: ${_courseController.text}',
                            style: TextStyle(
                              fontSize: height * 0.022,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            'Subject: ${_subjectController.text}',
                            style: TextStyle(
                              fontSize: height * 0.022,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.02),
                          provider.qrImage != null
                              ? Image.memory(
                                  provider.qrImage!,
                                  width: width * 0.8,
                                  height: width * 0.8,
                                )
                              : QrImageView(
                                  data: provider.qrData!,
                                  version: QrVersions.auto,
                                  size: width * 0.8,
                                ),
                          SizedBox(height: height * 0.02),
                          Text(
                            'Class ID: ${_classIdController.text}',
                            style: TextStyle(
                              fontSize: height * 0.022,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.04),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _resetForm,
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                              label: Text(
                                'Complete Class',
                                style: TextStyle(
                                  fontSize: height * 0.02,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: height * 0.02),
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(width * 0.02),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            // Show form view
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Course',
                      style: TextStyle(
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Autocomplete<Map<String, dynamic>>(
                      displayStringForOption: (option) => option['name'] ?? '',
                      optionsBuilder: (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.length > 2) {
                          await provider.getCourses(textEditingValue.text);
                          return provider.courses;
                        }
                        return const Iterable<Map<String, dynamic>>.empty();
                      },
                      onSelected: (Map<String, dynamic> selection) {
                        setState(() {
                          _selectedCourseId = selection['id'];
                          _courseController.text = selection['name'];
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _courseController = controller;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Type to search courses...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(width * 0.02),
                            ),
                          ),
                          validator: (value) {
                            if (_selectedCourseId == null) {
                              return 'Please select a course';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: height * 0.02),
                    Text(
                      'Select Subject',
                      style: TextStyle(
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Autocomplete<Map<String, dynamic>>(
                      displayStringForOption: (option) => option['name'] ?? '',
                      optionsBuilder: (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.length > 2) {
                          await provider.getSubjects(textEditingValue.text);
                          return provider.subjects;
                        }
                        return const Iterable<Map<String, dynamic>>.empty();
                      },
                      onSelected: (Map<String, dynamic> selection) {
                        setState(() {
                          _selectedSubjectId = selection['id'];
                          _subjectController.text = selection['name'];
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _subjectController = controller;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Type to search subjects...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(width * 0.02),
                            ),
                          ),
                          validator: (value) {
                            if (_selectedSubjectId == null) {
                              return 'Please select a subject';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: height * 0.02),
                    Text(
                      'Class ID',
                      style: TextStyle(
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    TextFormField(
                      controller: _classIdController,
                      decoration: InputDecoration(
                        hintText: 'Enter class ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(width * 0.02),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a class ID';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  provider.setLoading(true);
                                  final success = await provider.generateQR(
                                    courseId: _selectedCourseId!,
                                    subjectId: _selectedSubjectId!,
                                    classId: _classIdController.text,
                                  );
                                  provider.setLoading(false);

                                  if (!success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(provider.errorMessage),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      _showQR = true;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: height * 0.02),
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Generate QR Code',
                                style: TextStyle(
                                  fontSize: height * 0.02,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}