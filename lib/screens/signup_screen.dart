// import 'package:advertising_id/advertising_id.dart';
// import 'package:aimtech/app_constant/app_import.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../models/college_model.dart';
// import '../widget/signup_autocomplete.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _controllerName = TextEditingController();
//   final TextEditingController _controllerPhone = TextEditingController();
//   final TextEditingController _controllerStudentID = TextEditingController();
//   final TextEditingController _controllerAddress = TextEditingController();
//   final GlobalKey _autoCompleteKey = GlobalKey();
//
//   College? _selectedCollege;
//   CourseStream? selectedStream;
//   Department? selectedDepartment;
//   Semester? selectedSemester;
//   String? _advertisingId;
//
//   void _onSelectionChanged(
//       CourseStream? stream, Department? department, Semester? semester) {
//     setState(() {
//       selectedStream = stream;
//       selectedDepartment = department;
//       selectedSemester = semester;
//     });
//   }
//
//   Widget _buildAutocompleteOptionsView(BuildContext context,
//       Function(String) onSelected, Iterable<String> options, double width) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double itemHeight = screenHeight *
//         0.06; // Dynamically set item height (~6% of screen height)
//     double maxHeight = (options.length * itemHeight)
//         .clamp(0, screenHeight * 0.4); // Max height is 40% of screen
//     return Align(
//       alignment: Alignment.topLeft, // Position relative to the field
//       child: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: Material(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(width * 0.02),
//           ),
//           color: Colors.purple.shade100,
//           child: ConstrainedBox(
//             constraints:
//                 BoxConstraints(maxWidth: width * 0.8, maxHeight: maxHeight),
//             child: ListView.builder(
//               padding: EdgeInsets.zero,
//               itemCount: options.length,
//               itemBuilder: (BuildContext context, int index) {
//                 final String option = options.elementAt(index);
//                 return ListTile(
//                   title: Text(option),
//                   onTap: () => onSelected(option),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _getAdvertisingId() async {
//     try {
//       String? id =
//           await AdvertisingId.id(true); // true means limit tracking is checked
//       setState(() {
//         _advertisingId = id;
//       });
//     } catch (e) {
//       throw Exception("Error fetching Advertising ID: $e");
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _getAdvertisingId();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double height = MediaQuery.of(context).size.height;
//     final double width = MediaQuery.of(context).size.width;
//
//     final style =
//         TextStyle(fontWeight: FontWeight.w400, fontSize: height * 0.018);
//     final decoration = InputDecoration(
//       border:
//           OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.02)),
//       isDense: true,
//       contentPadding: EdgeInsets.all(height * 0.01),
//     );
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Student Sign Up"),
//         foregroundColor: Colors.white,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(colors: [Colors.purple, Colors.indigo]),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: width * 0.1),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: height * 0.01),
//                 _buildLabel("Full Name", height),
//                 _buildTextField(_controllerName, "Enter your full name", width,
//                     height, Icons.person),
//                 SizedBox(height: height * 0.014),
//                 _buildLabel("Phone Number", height),
//                 _buildTextField(_controllerPhone, "Enter your phone number",
//                     width, height, Icons.phone,
//                     isPhone: true),
//                 SizedBox(height: height * 0.014),
//                 _buildLabel("Address", height),
//                 _buildTextField(_controllerAddress, "Enter your address", width,
//                     height, Icons.home),
//                 SizedBox(height: height * 0.014),
//                 _buildLabel("Student ID", height),
//                 _buildTextField(_controllerStudentID, "Enter your student ID",
//                     width, height, Icons.badge),
//                 SizedBox(height: height * 0.014),
//                 _buildLabel("College", height),
//                 Consumer<CollegeProvider>(builder: (context, provider, _) {
//                   return Autocomplete<String>(
//                     key: _autoCompleteKey,
//                     optionsBuilder: (TextEditingValue textEditingValue) async {
//                       if (textEditingValue.text.isEmpty) {
//                         return const Iterable<String>.empty();
//                       }
//                       if (textEditingValue.text.length > 3) {
//                         await provider.getColleges(textEditingValue.text);
//                       }
//
//                       return provider.colleges
//                           .where((option) =>
//                               option["name"].toLowerCase().contains(
//                                   textEditingValue.text.toLowerCase()) ||
//                               option["code"].toLowerCase().contains(
//                                   textEditingValue.text.toLowerCase()))
//                           .map((option) => option["name"]);
//                     },
//                     onSelected: (String selection) async {
//                       final code = provider.colleges.firstWhere(
//                           (college) => college['name'] == selection)['code'];
//                       final focusScope = FocusScope.of(context);
//                       await provider.getSingleCollege(code);
//                       if (!mounted) return;
//                       final selectedCollege = provider.selectedCollege?.college;
//                       setState(() {
//                         _selectedCollege = selectedCollege;
//                       });
//                       focusScope.unfocus();
//                     },
//                     fieldViewBuilder:
//                         (context, controller, focusNode, onEditingComplete) {
//                       return TextFormField(
//                         controller: controller,
//                         focusNode: focusNode,
//                         onEditingComplete: onEditingComplete,
//                         decoration: decoration.copyWith(
//                             hintText: "Start typing to select your college.",
//                             prefixIcon: const Icon(Icons.account_balance)),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "please select a college";
//                           }
//                           return null;
//                         },
//                       );
//                     },
//                     optionsViewBuilder: (context, onSelected, options) =>
//                         _buildAutocompleteOptionsView(
//                             context, onSelected, options, width),
//                   );
//                 }),
//                 SizedBox(height: height * 0.014),
//                 Consumer<CollegeProvider>(builder: (context, provider, _) {
//                   return provider.selectedCollege != null
//                       ? StreamDepartmentSemesterSelection(
//                           colleges: provider.selectedCollege!,
//                           onSelectionChanged: _onSelectionChanged,
//                         )
//                       : const SizedBox();
//                 }),
//                 SizedBox(height: height * 0.04),
//                 _buildRegisterButton(width, height, style),
//                 SizedBox(height: height * 0.014),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLabel(String text, double height) {
//     return Row(
//       children: [
//         Text(text,
//             style: TextStyle(
//                 fontWeight: FontWeight.w400, fontSize: height * 0.018)),
//         const SizedBox(width: 4),
//         const Text("*", style: TextStyle(color: Colors.red)),
//       ],
//     );
//   }
//
//   Widget _buildTextField(
//     TextEditingController controller,
//     String hint,
//     double width,
//     double height,
//     IconData icon, {
//     bool isEmail = false,
//     bool isPhone = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       textCapitalization: TextCapitalization.characters,
//       keyboardType: isEmail
//           ? TextInputType.emailAddress
//           : isPhone
//               ? TextInputType.phone
//               : TextInputType.text,
//       decoration: InputDecoration(
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(width * 0.02)),
//         isDense: true,
//         contentPadding: EdgeInsets.all(height * 0.01),
//         prefixIcon: Icon(icon),
//         hintText: hint,
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return "Please ${hint.toLowerCase()}";
//         }
//         if (isEmail &&
//             !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                 .hasMatch(value)) {
//           return "Enter a valid email";
//         }
//         if (isPhone && !RegExp(r"^[0-9]{10}$").hasMatch(value)) {
//           return "Enter a valid 10-digit phone number";
//         }
//         return null;
//       },
//     );
//   }
//
//   Widget _buildRegisterButton(double width, double height, TextStyle style) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(width * 0.01),
//         gradient: const LinearGradient(colors: [Colors.purple, Colors.indigo]),
//       ),
//       child: ElevatedButton(
//         onPressed: () async {
//           if (_formKey.currentState!.validate()) {
//             final provider = Provider.of<UserProvider>(context, listen: false);
//             String name = _controllerName.text.trim();
//             String phone = _controllerPhone.text.trim();
//             String studentId = _controllerStudentID.text.trim();
//             String address = _controllerAddress.text.trim();
//             String collegeCode = _selectedCollege!.code;
//             String streamName = selectedStream!.name;
//             String departmentName = selectedDepartment!.name;
//             String semName = selectedSemester!.name;
//             String deviceId = _advertisingId ?? "";
//             await provider.register(
//               name,
//               studentId,
//               phone,
//               address,
//               collegeCode,
//               streamName,
//               departmentName,
//               semName,
//               deviceId,
//             );
//
//             if (provider.successMessage.isNotEmpty) {
//               if (!mounted) return;
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                     content: Text(provider.successMessage),
//                     backgroundColor: Colors.green),
//               );
//               navigateHome();
//             } else if (provider.errorMessage.isNotEmpty) {
//               if (!mounted) return;
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                     content: Text(provider.errorMessage),
//                     backgroundColor: Colors.red),
//               );
//             }
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           foregroundColor: Colors.white,
//           fixedSize: Size.fromWidth(width),
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(width * 0.02)),
//         ),
//         child: Text("Register", style: style),
//       ),
//     );
//   }
//
//   void navigateHome() {
//     Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
//   }
// }
