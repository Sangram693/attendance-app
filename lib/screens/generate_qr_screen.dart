import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  final TextEditingController _controller = TextEditingController();
  final _key = GlobalKey<FormState>();
  GlobalKey _courseAutoCompleteKey = GlobalKey();
  GlobalKey _subjectAutoCompleteKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void resetAutoComplete(CourseProvider provider) {
    provider.clearQrData();
    provider.setCourse("", "");
    provider.setSubject("", "");
    _controller.clear();
    _courseAutoCompleteKey = GlobalKey();
    _subjectAutoCompleteKey = GlobalKey();
  }

  void showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          msg,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR Code"),
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
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(width * 0.1),
            child: Form(
              key: _key,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (provider.qrImage == null) ...[
                      buildDropdown(
                        context,
                        width,
                        "Course",
                        "*",
                        _courseAutoCompleteKey,
                        (value) async {
                          await provider.getCourses(value);
                          return provider.courses
                              .map((e) => e["name"].toString())
                              .toList();
                        },
                        (selection) {
                          final id = provider.courses
                              .firstWhere((e) => e["name"] == selection)["id"];
                          provider.setCourse(selection, id.toString());
                        },
                      ),
                      SizedBox(height: width * 0.03),
                      buildDropdown(
                        context,
                        width,
                        "Subject",
                        "*",
                        _subjectAutoCompleteKey,
                        (value) async {
                          await provider.getSubjects(value);
                          return provider.subjects
                              .map((e) => e["name"].toString())
                              .toList();
                        },
                        (selection) {
                          final id = provider.subjects
                              .firstWhere((e) => e["name"] == selection)["id"];
                          provider.setSubject(selection, id.toString());
                        },
                      ),
                      SizedBox(height: width * 0.03),
                      buildLabel(width, "Class", required: true),
                      SizedBox(height: width * 0.02),
                      TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: width * 0.02),
                          hintText: "Enter class here",
                        ),
                      ),
                      SizedBox(height: width * 0.03),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width * 0.01),
                          gradient: LinearGradient(
                            colors: provider.isLoading
                                ? [Colors.grey, Colors.grey]
                                : [Colors.purple, Colors.indigo],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                                  if (_key.currentState!.validate() &&
                                      provider.courseId != null &&
                                      provider.subjectId != null) {
                                    provider.setLoading(true);
                                    bool success = await provider.generateQR(
                                      courseId: provider.courseId!,
                                      subjectId: provider.subjectId!,
                                      classId: _controller.text,
                                    );
                                    provider.setLoading(false);
                                    if (!success) {
                                      showMessage(
                                          provider.errorMessage, Colors.red);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width * 0.01),
                            ),
                            fixedSize: Size.fromWidth(width),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text(
                                  "SUBMIT",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (provider.qrImage != null) ...[
                      Image.memory(
                        provider.qrImage!,
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Text("Failed to load QR code"),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width * 0.01),
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.indigo],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => resetAutoComplete(provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            "Class Completed",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildLabel(double width, String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: width * 0.04),
        ),
        if (required)
          Text("*",
              style: TextStyle(color: Colors.red, fontSize: width * 0.04)),
      ],
    );
  }

  Widget buildDropdown(
    BuildContext context,
    double width,
    String label,
    String requiredMark,
    Key key,
    Future<List<String>> Function(String) optionsBuilder,
    void Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(width, label, required: true),
        SizedBox(height: width * 0.02),
        Autocomplete<String>(
          key: key,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return await optionsBuilder(textEditingValue.text);
          },
          onSelected: onSelected,
          fieldViewBuilder:
              (context, controller, focusNode, onEditingComplete) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: width * 0.02),
                hintText: "Start typing to select $label.",
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: width * 0.8,
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
