import 'dart:convert';
import 'dart:io';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:nexus_hr/screens/homepage.dart';
import 'package:nexus_hr/utils/api-endpoint.dart';
import 'package:http/http.dart' as http;

class CameraPageWidget extends StatefulWidget {
  final Function(String, String) inTime;
  final Function(String, String) outTime;

  const CameraPageWidget(
      {Key? key, required this.inTime, required this.outTime})
      : super(key: key);

  @override
  _CameraPageWidgetState createState() => _CameraPageWidgetState();
}

class _CameraPageWidgetState extends State<CameraPageWidget> {
  Future<void> _userAttendance(File userImage) async {
    try {
      final storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'accessToken');

      String? userImageConvert;
      userImageConvert = base64Encode((userImage).readAsBytesSync());

      final response = await http.post(
        Uri.parse(
            ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.userAttendance),
        body: jsonEncode({
          'userImage': userImageConvert,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['overtimeStatus'] == 'unknown') {
          final timeIn24HourFormat =
              DateFormat.Hm().parse(responseData['timeIn']);
          final timeIn12HourFormat = DateFormat.jm().format(timeIn24HourFormat);
          Get.close(1);
          if (responseData['attendanceStatus'] == 'late') {
            widget.inTime(timeIn12HourFormat, responseData['timeLate']);
            widget.outTime('00:00', '00:00');
            Get.snackbar(
              'Checked In',
              'You are late today.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          } else {
            widget.inTime(timeIn12HourFormat, '00:00');
            widget.outTime('00:00', '00:00');
            Get.snackbar(
              'Checked In',
              'You are on time.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } else if (responseData['status'] != 'unknown') {
          final timeOut24HourFormat =
              DateFormat.Hm().parse(responseData['timeOut']);
          final timeOut12HourFormat =
              DateFormat.jm().format(timeOut24HourFormat);

          if (responseData['overtimeStatus'] == 'yes') {
            widget.outTime(timeOut12HourFormat, responseData['overtime']);
            Get.close(1);
            Get.snackbar(
              'Checked Out',
              'You are checked out and have overtime.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          } else {
            widget.outTime(timeOut12HourFormat, '00:00');
            Get.close(1);
            Get.snackbar(
              'Checked Out',
              'You are checked out.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } else if (responseData['status'] == 'Error') {
          Get.snackbar(
            'Error',
            responseData['message'],
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (response.statusCode == 201) {
        Get.close(1);
        Get.snackbar(
          'Error',
          responseData['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.close(1);
        Get.snackbar(
          'Error',
          responseData['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('#F7DCD0'),
          elevation: 0,
          title: Text(
            'Take Attendance',
            style: GoogleFonts.roboto(
              color: Color(0xFF000000),
              fontWeight: FontWeight.w500,
              fontSize: 22,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SmartFaceCamera(
            autoCapture: true,
            enableAudio: false,
            showControls: false,
            showCaptureControl: false,
            showFlashControl: false,
            showCameraLensControl: false,
            defaultCameraLens: CameraLens.front,
            onCapture: (File? image) async {
              if (image != null) {
                _userAttendance(image);
              }
            },
            messageBuilder: (context, face) {
              if (face == null) {
                return _message('Place your face in the camera');
              }
              if (!face.wellPositioned) {
                return _message('Center your face in the square');
              }
              return const SizedBox.shrink();
            }));
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
        child: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: Colors.red)),
      );
}
