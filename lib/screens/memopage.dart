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

class MemoPageWidget extends StatefulWidget {
  const MemoPageWidget({Key? key}) : super(key: key);

  @override
  State<MemoPageWidget> createState() => _MemoPageWidgetState();
}

class _MemoPageWidgetState extends State<MemoPageWidget> {
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
              'Memo Page',
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
                    buildNavBarItem(Icons.message, 0),
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
                  height: screenHeight * 0.72,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
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
        return MemoWidget(key: Key('pending'), memoStatus: 'pending');
      case 1:
        return MemoWidget(key: Key('done'), memoStatus: 'done');
      default:
        return Container();
    }
  }

  String getContent(int index) {
    String title = '';
    switch (index) {
      case 0:
        title = 'Memo';
        break;
      case 1:
        title = 'Acknowledged';
        break;
      default:
        title = '';
    }
    return title;
  }
}

class MemoModel {
  String memoTo;
  String memoFrom;
  String memoDate;
  String memoSubject;
  String memoMessage;
  String memoStatus;
  String memoId;
  bool isExpanded;
  MemoModel(
    this.memoTo,
    this.memoFrom,
    this.memoDate,
    this.memoSubject,
    this.memoMessage,
    this.memoStatus,
    this.memoId,
  ) : isExpanded = false;
}

class MemoWidget extends StatefulWidget {
  const MemoWidget({Key? key, required this.memoStatus}) : super(key: key);

  final String memoStatus;
  @override
  _MemoWidgetState createState() => _MemoWidgetState();
}

class _MemoWidgetState extends State<MemoWidget> {
  Future<List<MemoModel>>? _claimsFuture;
  List<MemoModel> _claims = [];
  late TextEditingController _searchController;
  bool isChecked = false;
  @override
  void initState() {
    super.initState();
    _claimsFuture = _getMemoPending();
    _searchController = TextEditingController();
  }

  Future<List<MemoModel>> _getMemoPending() async {
    List<MemoModel> _leaves = [];
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userMemo}?memoStatus=${widget.memoStatus}'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        List<dynamic> responseBody = jsonDecode(response.body);
        _leaves = responseBody.map<MemoModel>((item) {
          DateTime parseLeaveApply =
              DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(item['memoDate']);
          String leaveApplyDate =
              DateFormat('d MMMM yyyy').format(parseLeaveApply);

          return MemoModel(
            item['userFullName'].toString(),
            item['adminFullname'],
            leaveApplyDate,
            item['memoSubject'],
            item['memoDetail'],
            item['memoStatus'],
            item['memoId'].toString(),
          );
        }).toList();
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No Memo found. Please try again later.'),
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

  void _acknowledgeMemo(String memoId) async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      final response = await http.post(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userMemo}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'memoId': memoId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memo acknowledged.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error acknowledging memo. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: FutureBuilder<List<MemoModel>>(
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
          labelText: 'Filter Memos',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  List<MemoModel> _filterClaims(List<MemoModel> leave) {
    if (_searchController.text.isEmpty) {
      return leave;
    } else {
      String query = _searchController.text.toLowerCase();
      return leave.where((leave) {
        return leave.memoTo.toLowerCase().contains(query) ||
            leave.memoFrom.toLowerCase().contains(query) ||
            leave.memoSubject.toLowerCase().contains(query) ||
            leave.memoMessage.toLowerCase().contains(query);
      }).toList();
    }
  }

  Widget _renderSteps(List<MemoModel> memos) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            memos[index].isExpanded = !memos[index].isExpanded;
          });
        },
        children: memos.map<ExpansionPanel>((MemoModel leaves) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(leaves.memoDate.toString(),
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    if (leaves.memoStatus == 'pending')
                      Image.asset('assets/icon/clock.png',
                          width: 24.0, height: 24.0),
                    if (leaves.memoStatus == 'done')
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
                  Table(
                    border: TableBorder.all(),
                    columnWidths: {
                      0: FractionColumnWidth(.2),
                      1: FractionColumnWidth(.8),
                    },
                    children: [
                      TableRow(children: [
                        Container(
                          color: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('To',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(leaves.memoTo,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ]),
                      TableRow(children: [
                        Container(
                          color: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('From',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text("${leaves.memoFrom} (Admin)",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ]),
                      TableRow(children: [
                        Container(
                          color: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('Date',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(leaves.memoDate,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ]),
                      TableRow(children: [
                        Container(
                          color: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text('Subject',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(leaves.memoSubject,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ]),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('MESSAGE:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(leaves.memoMessage,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 40),
                  if (leaves.memoStatus == 'pending')
                    Center(
                      child: Row(
                        children: <Widget>[
                          Text('Acknowledge Memo',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Checkbox(
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                                if (isChecked) {
                                  _acknowledgeMemo(leaves.memoId);
                                  _claimsFuture = _getMemoPending();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
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
