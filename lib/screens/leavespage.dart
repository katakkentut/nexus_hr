// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

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

class LeavesPageWidget extends StatefulWidget {
  const LeavesPageWidget({Key? key}) : super(key: key);

  @override
  State<LeavesPageWidget> createState() => _LeavesPageWidgetState();
}

class _LeavesPageWidgetState extends State<LeavesPageWidget> {
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
              'Leaves Page',
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
                top: screenHeight * 0.11,
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildNavBarItem(Icons.monetization_on, 0),
                    SizedBox(width: screenWidth * 0.03),
                    buildNavBarItem(Icons.history_rounded, 1),
                    SizedBox(width: screenWidth * 0.03),
                  ],
                ),
              ),
              Positioned(
                top: screenHeight * 0.20,
                left: screenWidth * 0.05,
                child: Text(
                  getContent(selectedIndex),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.24,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                child: Container(
                  height: screenHeight * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: getContentWidget(selectedIndex),
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
            child: index == 0
                ? buildCustomSettingsIcon()
                : Icon(
                    icon,
                    size: screenWidth * 0.14,
                  ),
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }

  Widget buildCustomSettingsIcon() {
    return Center(
      child: Image.asset(
        'assets/icon/exit.png',
        width: screenWidth * 0.12,
        height: screenHeight * 0.12,
      ),
    );
  }

  Widget getContentWidget(int index) {
    switch (index) {
      case 0:
        return LeavesWidget();
      case 1:
        return ClaimHistoryWidget();
      default:
        return Container();
    }
  }

  String getContent(int index) {
    String title = '';
    switch (index) {
      case 0:
        title = 'Apply Leave';
        break;
      case 1:
        title = 'Leaves History';
        break;
      default:
        title = '';
    }
    return title;
  }
}

class LeavesWidget extends StatefulWidget {
  const LeavesWidget({Key? key}) : super(key: key);

  @override
  _LeavesWidgetState createState() => _LeavesWidgetState();
}

class _LeavesWidgetState extends State<LeavesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController leavesReasonController = TextEditingController();
  TextEditingController leavesStartDateController = TextEditingController();
  TextEditingController leavesEndDateController = TextEditingController();
  final leavesDurationController = TextEditingController();
  FocusNode leavesReasonFocusNode = FocusNode();
  FocusNode leavesStartDateFocusNode = FocusNode();
  FocusNode leavesEndDateFocusNode = FocusNode();
  FocusNode leavesDurationFocusNode = FocusNode();
  bool startDateSelected = false;
  bool endDateSelected = false;
  final _formKey = GlobalKey<FormState>();
  late double screenWidth = 0.0;
  late double screenHeight = 0.0;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    leavesReasonController.dispose();
    leavesStartDateController.dispose();
    leavesEndDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _getPersonalDetail();
  //   });
  // }

  // void _getPersonalDetail() async {
  //   final storage = FlutterSecureStorage();
  //   final accessToken = await storage.read(key: 'accessToken');
  //   final userid = await storage.read(key: 'userid');

  //   if (accessToken != null) {
  //     final response = await http.get(
  //       Uri.parse(
  //           '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.personalDetail}?staffId=$userid'),
  //       headers: {'Authorization': 'Bearer $accessToken'},
  //     );

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       if (mounted) {
  //         setState(() {
  //           fullNameController.text = responseData['userFullName'];
  //           religionController.text = responseData['userReligion'];
  //           raceController.text = responseData['userRace'];
  //           nationalityController.text = responseData['userNationality'];
  //           idNumberController.text = responseData['userId'].toString();
  //         });
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error loading data. Please try again later.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _insertLeave(String leaveReason, String startDate,
      String endDate, String leaveDuration) async {
    try {
      final storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'accessToken');

      String? attachment;
      if (_image != null) {
        if (_image is File) {
          attachment = base64Encode((_image as File).readAsBytesSync());
        } else {
          attachment = null;
        }
      }

      final dateFormat = DateFormat('d MMM yyyy');
      final startDate = dateFormat.parse(leavesStartDateController.text);
      final endDate = dateFormat.parse(leavesEndDateController.text);
      final startDateString = startDate.toIso8601String();
      final endDateString = endDate.toIso8601String();

      final response = await http.post(
        Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.userLeave),
        body: jsonEncode({
          'leaveReason': leaveReason,
          'leaveStart': startDateString,
          'leaveEnd': endDateString,
          'leaveDuration': leaveDuration,
          'attachment': attachment,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inserting leaves. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _calculateLeaveDuration() {
    if (leavesStartDateController.text.isNotEmpty &&
        leavesEndDateController.text.isNotEmpty) {
      final dateFormat = DateFormat('d MMM yyyy');
      final startDate = dateFormat.parse(leavesStartDateController.text);
      final endDate = dateFormat.parse(leavesEndDateController.text);
      final duration = endDate.difference(startDate).inDays + 1;
      leavesDurationController.text = '$duration Days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FormWidget.buildInput(
                'Leave Reason',
                leavesReasonController,
                leavesReasonFocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your leave reason';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DateFormWidget.buildInput(
                context,
                'Leaves Start Date',
                leavesStartDateController,
                leavesStartDateFocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your leave start date';
                  }
                  return null;
                },
                isDisabled: true,
                onChanged: (value) {
                  startDateSelected = true;
                  _calculateLeaveDuration();
                },
              ),
              SizedBox(height: 10),
              DateFormWidget.buildInput(
                context,
                'Leaves End Date',
                leavesEndDateController,
                leavesEndDateFocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the leave end date';
                  }
                  return null;
                },
                isDisabled: true,
                onChanged: (value) {
                  endDateSelected = true;
                  _calculateLeaveDuration();
                },
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'Leave Duration',
                leavesDurationController,
                leavesDurationFocusNode,
                TextInputType.text,
                isDisabled: true,
              ),
              SizedBox(height: 10),
              buildImageUploadForm('Upload Attachment'),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _insertLeave(
                          leavesReasonController.text,
                          leavesStartDateController.text,
                          leavesEndDateController.text,
                          leavesDurationController.text,
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(HexColor('#9AD0D3')),
                    ),
                    child: Text(
                      'Submit Leaves',
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
        ),
      ),
    );
  }

  Widget buildImageUploadForm(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity, // takes the full width
              height: 200, // adjust the height as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: _image == null
                  ? Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey,
                    )
                  : Image.file(
                      _image!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: ElevatedButton(
                onPressed: () {
                  _pickImage();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(8),
                  primary: Colors.blue,
                  shape: CircleBorder(),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

class LeaveHistory {
  String title;
  String leaveId;
  String leaveReason;
  String leaveStart;
  String leaveEnd;
  String leaveDuration;
  String leaveStatus;
  bool isExpanded;
  LeaveHistory(
    this.title,
    this.leaveId,
    this.leaveReason,
    this.leaveStart,
    this.leaveEnd,
    this.leaveDuration,
    this.leaveStatus,
  ) : isExpanded = false;
}

class ClaimHistoryWidget extends StatefulWidget {
  const ClaimHistoryWidget({Key? key}) : super(key: key);

  @override
  _ClaimHistoryWidgetState createState() => _ClaimHistoryWidgetState();
}

class _ClaimHistoryWidgetState extends State<ClaimHistoryWidget> {
  Future<List<LeaveHistory>>? _claimsFuture;
  List<LeaveHistory> _claims = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _claimsFuture = _getUserLeaves();
    _searchController = TextEditingController();
  }

  Future<List<LeaveHistory>> _getUserLeaves() async {
    List<LeaveHistory> _leaves = [];
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userLeave}?staffId=$userid'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        List<dynamic> responseBody = jsonDecode(response.body);

        _leaves = responseBody.map<LeaveHistory>((item) {
          DateTime parseLeaveApply =
              DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(item['leaveEnd']);
          String leaveApplyDate =
              DateFormat('d MMMM yyyy').format(parseLeaveApply);

          DateTime parseLeaveStart =
              DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(item['leaveStart']);
          String leaveStartFormat =
              DateFormat('d MMMM yyyy').format(parseLeaveStart);

          DateTime parseLeaveEnd =
              DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(item['leaveEnd']);
          String leaveEndFormat =
              DateFormat('d MMMM yyyy').format(parseLeaveEnd);

          return LeaveHistory(
            leaveApplyDate,
            item['leaveId'].toString(),
            item['leaveReason'],
            leaveStartFormat,
            leaveEndFormat,
            item['leaveDuration'],
            item['leaveStatus'],
          );
        }).toList();
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No Leaves found. Please try again later.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return _leaves;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: FutureBuilder<List<LeaveHistory>>(
        future: _claimsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            _claims = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildSearchInput(),
                    _renderSteps(_filterClaims(_claims)),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Filter Leaves',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  List<LeaveHistory> _filterClaims(List<LeaveHistory> leave) {
    if (_searchController.text.isEmpty) {
      return leave;
    } else {
      String query = _searchController.text.toLowerCase();
      return leave.where((leave) {
        return leave.leaveReason.toLowerCase().contains(query) ||
            leave.leaveId.toLowerCase().contains(query) ||
            leave.leaveStart.toLowerCase().contains(query) ||
            leave.leaveEnd.toLowerCase().contains(query) ||
            leave.leaveDuration.toLowerCase().contains(query) ||
            leave.leaveStatus.toLowerCase().contains(query);
      }).toList();
    }
  }

  Widget _renderSteps(List<LeaveHistory> leaves) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            leaves[index].isExpanded = !leaves[index].isExpanded;
          });
        },
        children: leaves.map<ExpansionPanel>((LeaveHistory leaves) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(leaves.title,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    if (leaves.leaveStatus == 'pending')
                      Image.asset('assets/icon/clock.png',
                          width: 24.0, height: 24.0),
                    if (leaves.leaveStatus == 'rejected')
                      Image.asset('assets/icon/reject.png',
                          width: 24.0, height: 24.0),
                    if (leaves.leaveStatus == 'approved')
                      Image.asset('assets/icon/check-mark.png',
                          width: 24.0, height: 24.0),
                  ],
                ),
              );
            },
            body: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Leave Id',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text("# ${leaves.leaveId}", style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Leave Reason',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(leaves.leaveReason, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Leave Start',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(leaves.leaveStart, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Leave End',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(leaves.leaveEnd, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Leave Duration',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(leaves.leaveDuration, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Leave Status',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(leaves.leaveStatus, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            isExpanded: leaves.isExpanded,
            canTapOnHeader: true,
          );
        }).toList(),
      ),
    );
  }
}
