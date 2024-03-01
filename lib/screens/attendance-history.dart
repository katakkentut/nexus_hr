// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, prefer_const_declarations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nexus_hr/forms/button.dart';
import 'package:nexus_hr/forms/datepicker.dart';
import 'package:nexus_hr/forms/form.dart';
import 'package:nexus_hr/utils/api-endpoint.dart';

class AttendanceHistoryWidget extends StatefulWidget {
  const AttendanceHistoryWidget({Key? key}) : super(key: key);

  @override
  State<AttendanceHistoryWidget> createState() =>
      _AttendanceHistoryWidgetState();
}

class _AttendanceHistoryWidgetState extends State<AttendanceHistoryWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  late double screenWidth = 0.0;
  late double screenHeight = 0.0;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return MediaQuery(
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
        child: Scaffold(
          key: scaffoldKey,
          extendBodyBehindAppBar: true,
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Attendance History Page',
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
          body: Stack(
            children: [
              Image.asset(
                'assets/background/bg1.png',
                width: screenWidth,
                height: screenHeight,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: screenHeight * 0.14,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                child: Container(
                  height: screenHeight * 0.81,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AttendanceWidget(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildNavBarItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        children: [
          Container(
            width: screenWidth * 0.15,
            height: screenHeight * 0.08,
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
              icon,
              size: screenWidth * 0.14,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}

class AttendanceModel {
  String attendanceMonth;
  int attendanceId;
  int userId;
  String attendanceDate;
  String timeIn;
  String timeOut;
  String timeLate;
  String overtime;
  String attendanceStatus;
  String overtimeStatus;

  bool isExpanded;

  AttendanceModel({
    required this.attendanceMonth,
    required this.attendanceId,
    required this.userId,
    required this.attendanceDate,
    required this.timeIn,
    required this.timeOut,
    required this.timeLate,
    required this.overtime,
    required this.attendanceStatus,
    required this.overtimeStatus,
    this.isExpanded = false,
  });

  factory AttendanceModel.fromJson(String month, Map<String, dynamic> json) {
    List<String> timeParts = (json['timeLate'] as String).split(':');
    String formattedTimeLate =
        '${timeParts[0]} hours and ${timeParts[1]} minutes';

   

    return AttendanceModel(
      attendanceMonth: month,
      attendanceId: json['attendanceId'] as int,
      userId: json['userId'] as int,
      attendanceDate: json['attendanceDate'],
      timeIn: json['timeIn'],
      timeOut: json['timeOut'],
      timeLate: formattedTimeLate,
      overtime: '${json['overtime']} hours',
      attendanceStatus: json['attendanceStatus'],
      overtimeStatus: json['overtimeStatus'],
    );
  }
}

class AttendanceWidget extends StatefulWidget {
  @override
  _AttendanceWidgetState createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  Future<Map<String, List<AttendanceModel>>>? _attendanceHistoryFuture;
  Map<String, List<AttendanceModel>> _groupedAttendances = {};
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _attendanceHistoryFuture = _getAttendanceHistory();
    _searchController = TextEditingController();
  }

  Future<Map<String, List<AttendanceModel>>> _getAttendanceHistory() async {
    final Map<String, List<AttendanceModel>> groupedAttendance = {};
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userAttendance}'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        responseBody.forEach((month, attendances) {
          groupedAttendance[month] = (attendances as List)
              .map((attendanceJson) =>
                  AttendanceModel.fromJson(month, attendanceJson))
              .toList();
        });
        return groupedAttendance;
      } else {
        throw Exception('Failed to load attendance data');
      }
    } else {
      throw Exception('Access Token is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: FutureBuilder<Map<String, List<AttendanceModel>>>(
        future: _attendanceHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            _groupedAttendances = snapshot.data ?? {};
            return SingleChildScrollView(
              child: Container(
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                child: Column(
                  children: <Widget>[
                    _renderGroupedAttendance(_groupedAttendances),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _renderGroupedAttendance(
      Map<String, List<AttendanceModel>> groupedAttendance) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: groupedAttendance.keys.length,
      itemBuilder: (context, index) {
        String month = groupedAttendance.keys.elementAt(index);
        List<AttendanceModel> records = groupedAttendance[month]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ExpansionTile(
              backgroundColor: Colors.white,
              title: Text(
                DateFormat('MMM yyyy')
                    .format(DateFormat('yyyy-MM').parse(month)),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              children: records.map((record) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Card(
                    elevation: 1,
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                DateFormat('MMM dd, yyyy').format(
                                    DateFormat('yyyy-MM-dd')
                                        .parse(record.attendanceDate)),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (record.attendanceStatus == 'late')
                                Icon(Icons.remove_circle, color: Colors.red)
                              else
                                Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                          SizedBox(height: 10),
                          Table(
                            columnWidths: const {
                              0: FractionColumnWidth(.3),
                              1: FractionColumnWidth(.7),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Text(
                                    'Time In:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(
                                        DateFormat('H:mm:ss')
                                            .parse(record.timeIn)),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'Time Out:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(
                                        DateFormat('H:mm:ss')
                                            .parse(record.timeOut)),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'Status:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    record.attendanceStatus,
                                    style: TextStyle(
                                      color: record.attendanceStatus == 'on time'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'Time Late:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(record.timeLate),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'Overtime:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(record.overtimeStatus),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'Overtime Hr:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(record.overtime),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
