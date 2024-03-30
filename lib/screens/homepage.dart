// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:nexus_hr/screens/attendance-history.dart';
import 'package:nexus_hr/screens/attendancepage.dart';
import 'package:nexus_hr/screens/auth/signin.dart';
import 'package:nexus_hr/screens/claimspage.dart';
import 'package:nexus_hr/screens/leavespage.dart';
import 'package:nexus_hr/screens/memopage.dart';
import 'package:nexus_hr/screens/payslippage.dart';
import 'package:nexus_hr/screens/profilepage.dart';
import 'package:http/http.dart' as http;
import 'package:nexus_hr/screens/servicesdesk.dart';
import 'package:nexus_hr/screens/settingpage.dart';
import 'package:nexus_hr/utils/api-endpoint.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageWidget extends StatefulWidget {
  const HomepageWidget({super.key});

  @override
  State<HomepageWidget> createState() => _HomepageWidgetState();
}

class _HomepageWidgetState extends State<HomepageWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String userFullName = '';
  String profilePhoto = '';
  AnimationController? _controller;
  late double screenWidth = 0.0;
  late double screenHeight = 0.0;
  String inTime = '00:00';
  String outTime = '00:00';
  String lateTime = '00:00';
  String overTime = '00:00';

  void updateIntime(String newInTime, String newLateTime) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('inTime', newInTime);
    prefs.setString('date', DateTime.now().toIso8601String());
    prefs.setString('lateTime', newLateTime);
    setState(() {
      inTime = newInTime;
      lateTime = newLateTime;
    });
  }

  void updateOuttime(String newOutTime, String newOverTime) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('outTime', newOutTime);
    prefs.setString('date', DateTime.now().toIso8601String());
    prefs.setString('overTime', newOverTime);

    setState(() {
      outTime = newOutTime;
      overTime = newOverTime;
    });
  }

  void _loadTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = DateTime.parse(
        prefs.getString('date') ?? DateTime.now().toIso8601String());
    final currentDate = DateTime.now();

    if (storedDate.day == currentDate.day &&
        storedDate.month == currentDate.month &&
        storedDate.year == currentDate.year) {
      final storedInTime = prefs.getString('inTime') ?? '00:00';
      final storedOutTime = prefs.getString('outTime') ?? '00:00';
      final storedLateTime = prefs.getString('lateTime') ?? '00:00';
      final storedOverTime = prefs.getString('overTime') ?? '00:00';

      setState(() {
        inTime = storedInTime;
        outTime = storedOutTime;
        lateTime = storedLateTime;
        overTime = storedOverTime;
      });
    } else {
      prefs.setString('inTime', '00:00');
      prefs.setString('outTime', '00:00');
      prefs.setString('lateTime', '00:00');
      prefs.setString('overTime', '00:00');

      setState(() {
        inTime = '00:00';
        outTime = '00:00';
        lateTime = '00:00';
        overTime = '00:00';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      _loadData();
      _loadTime();
    });
  }

  void resetTimes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('inTime', '00:00');
    prefs.setString('outTime', '00:00');
    prefs.setString('lateTime', '00:00');
    prefs.setString('overTime', '00:00');

    setState(() {
      inTime = '00:00';
      outTime = '00:00';
      lateTime = '00:00';
      overTime = '00:00';
    });
  }

  void _loadData() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.homepage}?staffId=$userid'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          userFullName = responseData['userFullName'];
          profilePhoto =
              // ignore: prefer_interpolation_to_compose_strings
              "${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userProfile}/" +
                  responseData['userProfile'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return MediaQuery(
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
        child: Scaffold(
          key: scaffoldKey,
          body: Stack(
            children: [
              Image.asset(
                'assets/background/bg1.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              GestureDetector(
                onTap: () {
                  _logout();
                },
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'HR Nexus',
                          style: GoogleFonts.roboto(
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.w500,
                            fontSize: 35,
                          ),
                        ),
                        Icon(
                          Icons.logout_rounded,
                          color: Color(0xFF000000),
                          size: 30.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => ServiceDeskPageWidget());
                  },
                  child: Image.asset(
                    'assets/icon/costumer-service.png',
                    width: screenWidth * 0.16,
                    height: screenHeight * 0.16,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 250,
                left: MediaQuery.of(context).size.width / 2 - 60,
                child: FadeTransition(
                  opacity: _controller!,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(userFullName.isEmpty
                        ? 'https://via.placeholder.com/150'
                        : profilePhoto),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 + -120,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  userFullName,
                  style: GoogleFonts.roboto(
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 + -85,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  'HR Nexus System',
                  style: GoogleFonts.roboto(
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 380, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => LeavesPageWidget());
                      },
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, -0.13),
                            child: Container(
                              width: 61,
                              height: 68,
                              decoration: BoxDecoration(
                                color: HexColor('#9AD0D3'),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(-0.52, -0.18),
                                child: Icon(
                                  Icons.calendar_month,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                          Text('Leaves'),
                        ],
                      ),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => ClaimPageWidget());
                      },
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, -0.13),
                            child: Container(
                              width: 61,
                              height: 68,
                              decoration: BoxDecoration(
                                color: HexColor('#9AD0D3'),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(-0.52, -0.18),
                                child: buildCustomSettingsIcon(
                                    'assets/icon/refund.png'),
                              ),
                            ),
                          ),
                          Text('Claims'),
                        ],
                      ),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => PaySlipWidget());
                      },
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, -0.13),
                            child: Container(
                              width: 61,
                              height: 68,
                              decoration: BoxDecoration(
                                color: HexColor('#9AD0D3'),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(-0.52, -0.18),
                                child: Icon(
                                  Icons.monetization_on,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                          Text('Pay Slip'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 160,
                bottom: 50,
                left: 50,
                right: 50,
                child: Align(
                  alignment: AlignmentDirectional(0.01, 0.64),
                  child: Container(
                    width: 312,
                    height: 250,
                    decoration: BoxDecoration(
                      color: HexColor('#9AD0D3'),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    alignment: AlignmentDirectional(0, 0),
                    child: Stack(
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0, -1),
                          child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: Column(
                                children: [
                                  Text(
                                    'Attendance Overview',
                                    style: GoogleFonts.roboto(
                                      color: Color(0xFF000000),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat.yMMMd()
                                              .format(DateTime.now()),
                                          style: GoogleFonts.roboto(
                                            color: Color(0xFF000000),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.refresh),
                                          onPressed: resetTimes,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(35.0, 80.0, 35.0, 70.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'In',
                                    style: GoogleFonts.roboto(
                                      color: Color(0xFF000000),
                                      fontSize: 18,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Text(
                                      inTime,
                                      style: GoogleFonts.roboto(
                                        color: Color(0xFF000000),
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Late: $lateTime hrs',
                                    style: GoogleFonts.roboto(
                                      color: Colors.red[900],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Out',
                                    style: GoogleFonts.roboto(
                                      color: Color(0xFF000000),
                                      fontSize: 18,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Text(
                                      outTime,
                                      style: GoogleFonts.roboto(
                                        color: Color(0xFF000000),
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'OT: $overTime hrs',
                                    style: GoogleFonts.roboto(
                                      color: Colors.red[900],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => AttendanceHistoryWidget());
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                  ),
                                  child: Text(
                                    'View History',
                                    style: GoogleFonts.roboto(
                                      color: Color(0xFF000000),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 40,
                right: 40,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => MemoPageWidget());
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 61,
                              height: 68,
                              decoration: BoxDecoration(
                                color: HexColor('#9AD0D3'),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Icon(
                                Icons.message,
                                size: 60,
                              ),
                            ),
                            Text('Memo'),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => ProfilePageWidget());
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 61,
                              height: 68,
                              decoration: BoxDecoration(
                                color: HexColor('#9AD0D3'),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 60,
                              ),
                            ),
                            Text('Profile'),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => CameraPageWidget(
                              inTime: updateIntime, outTime: updateOuttime));
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 61,
                              height: 68,
                              decoration: BoxDecoration(
                                color: HexColor('#9AD0D3'),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 60,
                              ),
                            ),
                            Text('Attendance'),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      GestureDetector(
                        onTap: () => {
                          Get.to(() => SettingPageWidget()),
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 61,
                              height: 68,
                              decoration: BoxDecoration(
                                color: HexColor('#9AD0D3'),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Icon(
                                Icons.settings,
                                size: 60,
                              ),
                            ),
                            Text('Settings'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildCustomSettingsIcon(String iconPath) {
    return Center(
      child: Image.asset(
        iconPath,
        width: screenWidth * 0.12,
        height: screenHeight * 0.12,
      ),
    );
  }

  void _logout() async {
    Get.to(() => SignInWidget());
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'userid');
  }
}

mixin isIos {}
