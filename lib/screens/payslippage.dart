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

class PaySlipWidget extends StatefulWidget {
  const PaySlipWidget({Key? key}) : super(key: key);

  @override
  State<PaySlipWidget> createState() => _PaySlipWidgetState();
}

class _PaySlipWidgetState extends State<PaySlipWidget> {
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
              'Pay Slip Page',
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
                top: screenHeight * 0.12,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                child: Container(
                  height: screenHeight * 0.83,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PaySlip(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class PaySlipModel {
  String title;
  String fileName;
  bool isExpanded;
  PaySlipModel(
    this.title,
    this.fileName,
  ) : isExpanded = false;
}

class PaySlip extends StatefulWidget {
  const PaySlip({Key? key}) : super(key: key);

  @override
  _PaySlipState createState() => _PaySlipState();
}

class _PaySlipState extends State<PaySlip> {
  Future<List<PaySlipModel>>? _claimsFuture;
  List<PaySlipModel> _claims = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _claimsFuture = _getUserLeaves();
    _searchController = TextEditingController();
  }

  Future<List<PaySlipModel>> _getUserLeaves() async {
    List<PaySlipModel> _leaves = [];
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userPaySlip}?staffId=$userid'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        List<dynamic> responseBody = jsonDecode(response.body);
        _leaves = responseBody.map<PaySlipModel>((item) {
          return PaySlipModel(
            item['paySlipMonth'],
            ApiEndPoints.baseUrl +
                ApiEndPoints.authEndpoints.servePayslip +
                item['fileName'],
          );
        }).toList();
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No Pay Slip found. Please try again later.'),
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
      child: FutureBuilder<List<PaySlipModel>>(
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
          labelText: 'Filter Pay Slip',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  List<PaySlipModel> _filterClaims(List<PaySlipModel> payslip) {
    if (_searchController.text.isEmpty) {
      return payslip;
    } else {
      String query = _searchController.text.toLowerCase();
      return payslip.where((leave) {
        return leave.title.toLowerCase().contains(query);
      }).toList();
    }
  }

  Widget _renderSteps(List<PaySlipModel> leaves) {
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
        children: leaves.map<ExpansionPanel>((PaySlipModel leaves) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(leaves.title,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
            body: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
    
                  Image.network(
                    leaves.fileName, // Assuming this is the URL of the image
                    fit: BoxFit.cover, // Use BoxFit.contain if you want to see the whole image within the box
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
