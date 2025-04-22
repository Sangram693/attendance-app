import 'package:aimtech/app_constant/app_import.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({super.key});

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = "Scan a QR code";
  Color color = Colors.black;
  bool isScanning = true;
  bool hasPermissions = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLocationPermission();
    _checkCameraPermission();
  }

  /// ✅ Check and request camera permission
  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => hasPermissions = true);
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog("Camera");
    }
  }

  /// ✅ Check and request location permission
  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() => hasPermissions = true);
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog("Location");
    }
  }

  /// ✅ Show settings dialog if permission is permanently denied
  void _showSettingsDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permissions Required"),
        content: Text(
            "$permissionType permission is permanently denied. Please enable it from settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  /// ✅ Get user's location (latitude, longitude)
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => qrText = "Location services are disabled.");
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  /// ✅ Send scanned QR code & location to the API for attendance
  Future<void> markAttendance(String qrCode) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    
    // Check for both device ID and user ID
    final String? deviceId = await provider.getStudentData("deviceId");
    final String? userId = await provider.getStudentData("userId");
    
    if (deviceId == null || userId == null) {
      setState(() {
        qrText = "Error: User not properly authenticated";
        color = Colors.red;
        isScanning = false;
      });
      return;
    }

    Position? position = await _getCurrentLocation();
    if (position == null) return;

    final bool success = await provider.giveAttendance(
        position.latitude, position.longitude, qrCode, deviceId);
    final player = AudioPlayer();
    await player.play(AssetSource('sound.mp3'));
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.white,
            content: Text(
              provider.successMessage,
              style: const TextStyle(color: Colors.green),
            )));
        Navigator.pop(context);
      }
    } else {
      setState(() {
        qrText = provider.errorMessage;
        color = Colors.red;
        isScanning = false;
      });
    }
  }

  /// ✅ Handle QR code scanning
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (isScanning) {
        setState(() {
          isScanning = false;
        });

        if (scanData.code != null) {
          try {
            final provider = Provider.of<UserProvider>(context, listen: false);
            String? deviceId = await provider.getStudentData("deviceId");
            
            if (deviceId == null) {
              setState(() {
                qrText = "Device not authorized";
                color = Colors.red;
              });
              return;
            }

            String scannedJson = scanData.code!;
            Map<String, dynamic> scannedCode = jsonDecode(scannedJson);

            if (scannedCode.containsKey('courseId') && 
                scannedCode.containsKey('subjectId') && 
                scannedCode.containsKey('classId')) {
              // Format the data as needed for the API
              String attendanceData = json.encode({
                'courseId': scannedCode['courseId'],
                'subjectId': scannedCode['subjectId'],
                'classId': scannedCode['classId']
              });
              await markAttendance(attendanceData);
            } else {
              setState(() {
                qrText = "Invalid QR Code format";
                color = Colors.red;
              });
            }
          } catch (e) {
            setState(() {
              qrText = "Error reading QR Code";
              color = Colors.red;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.purple, Colors.indigo]),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                overlayColor: Colors.black,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 5,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                qrText,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
