import 'package:flutter/material.dart';

import '../models/college_model.dart';

class StreamDepartmentSemesterSelection extends StatefulWidget {
  final CollegeModel colleges;
  final Function(CourseStream? stream, Department? department, Semester? semester)? onSelectionChanged;
  const StreamDepartmentSemesterSelection({super.key, required this.colleges, this.onSelectionChanged});

  @override
  State<StreamDepartmentSemesterSelection> createState() => _StreamDepartmentSemesterSelectionState();
}

class _StreamDepartmentSemesterSelectionState extends State<StreamDepartmentSemesterSelection> {
  CourseStream? selectedStream;
  Department? selectedDepartment;
  Semester? selectedSemester;

  List<CourseStream> getStreams() {
    return widget.colleges.college.streams;
  }

  List<Department> getDepartments() {
    return selectedStream?.departments ?? [];
  }

  List<Semester> getSemesters() {
    return selectedDepartment?.semesters ?? [];
  }
  Widget _buildLabel(String text, double height) {
    return Row(
      children: [
        Text(text,
            style: TextStyle(
                fontWeight: FontWeight.w400, fontSize: height * 0.018)),
        const SizedBox(width: 4),
        const Text("*", style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildAutocompleteOptionsView<T>(BuildContext context, Function(T) onSelected, Iterable<T> options, double width) {
    double screenHeight = MediaQuery.of(context).size.height;
    double itemHeight = screenHeight * 0.06;
    double maxHeight = (options.length * itemHeight).clamp(0, screenHeight * 0.4);
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.02),
          ),
          color: Colors.purple.shade100,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width * 0.8, maxHeight: maxHeight),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final T option = options.elementAt(index);
                return ListTile(
                  title: Text((option as dynamic).name),
                  onTap: () => onSelected(option),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Stream", height),
        Autocomplete<CourseStream>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<CourseStream>.empty();
            }
            return getStreams().where((stream) =>
                stream.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          displayStringForOption: (stream) => stream.name,
          onSelected: (stream) {
            setState(() {
              selectedStream = stream;
              selectedDepartment = null;
              selectedSemester = null;
            });

            if (widget.onSelectionChanged != null) {
              widget.onSelectionChanged!(selectedStream, selectedDepartment, selectedSemester);
            }
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
                isDense: true,
                contentPadding: EdgeInsets.all(height * 0.01),
                hintText: "Start typing to select your stream.",
                prefixIcon: const Icon(Icons.stream),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) =>
              _buildAutocompleteOptionsView(context, onSelected, options, width),
        ),
        if (selectedStream != null)...[
          SizedBox(height: height * 0.014),
          _buildLabel("Department", height),
          Autocomplete<Department>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Department>.empty();
              }
              return getDepartments().where((dept) =>
                  dept.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            displayStringForOption: (dept) => dept.name,
            onSelected: (dept) {
              setState(() {
                selectedDepartment = dept;
                selectedSemester = null;
              });
              if (widget.onSelectionChanged != null) {
                widget.onSelectionChanged!(selectedStream, selectedDepartment, selectedSemester);
              }
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
                  isDense: true,
                  contentPadding: EdgeInsets.all(height * 0.01),
                  hintText: "Start typing to select your department.",
                  prefixIcon: const Icon(Icons.school),

                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) =>
                _buildAutocompleteOptionsView(context, onSelected, options, width),
          ),
        ],


        if (selectedDepartment != null)...[
          SizedBox(height: height * 0.014),
          _buildLabel("Semester", height),
          Autocomplete<Semester>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Semester>.empty();
              }
              return getSemesters().where((sem) =>
                  sem.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            displayStringForOption: (sem) => sem.name,
            onSelected: (sem) {
              setState(() {
                selectedSemester = sem;
              });

              if (widget.onSelectionChanged != null) {
                widget.onSelectionChanged!(selectedStream, selectedDepartment, selectedSemester);
              }
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
                  isDense: true,
                  contentPadding: EdgeInsets.all(height * 0.01),
                  hintText: "Start typing to select your semester.",
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) =>
                _buildAutocompleteOptionsView(context, onSelected, options, width),
          ),
      ],
    ]
    );
  }
}
