// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nexus_hr/forms/button.dart';
import 'package:nexus_hr/forms/form.dart';
import 'package:nexus_hr/utils/api-endpoint.dart';

class ServiceDeskPageWidget extends StatefulWidget {
  const ServiceDeskPageWidget({Key? key}) : super(key: key);

  @override
  State<ServiceDeskPageWidget> createState() => _ServiceDeskPageWidgetState();
}

class _ServiceDeskPageWidgetState extends State<ServiceDeskPageWidget> {
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
              'Services Page',
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
                  height: screenHeight * 0.73,
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
        'assets/icon/help-desk.png',
        width: screenWidth * 0.12,
        height: screenHeight * 0.12,
      ),
    );
  }

  Widget getContentWidget(int index) {
    switch (index) {
      case 0:
        return ServicesDesk();
      case 1:
        return ServiceHistoryWidget();
      default:
        return Container();
    }
  }

  String getContent(int index) {
    String title = '';
    switch (index) {
      case 0:
        title = 'Service Desk';
        break;
      case 1:
        title = 'Service Desk History';
        break;
      default:
        title = '';
    }
    return title;
  }
}

class ServicesDesk extends StatefulWidget {
  const ServicesDesk({Key? key}) : super(key: key);

  @override
  _ServicesDeskState createState() => _ServicesDeskState();
}

class _ServicesDeskState extends State<ServicesDesk> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController servicesProblemController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  FocusNode servicesProblemFocusNode = FocusNode();
  FocusNode userEmailFocusNode = FocusNode();
  FocusNode userIdFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  late double screenWidth = 0.0;
  late double screenHeight = 0.0;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    servicesProblemController.dispose();
    userEmailController.dispose();
    userIdController.dispose();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setUserDetail();
    });
  }

  void _setUserDetail() async {
    final storage = FlutterSecureStorage();
    final userEmail = await storage.read(key: 'userEmail');
    final userId = await storage.read(key: 'userid');
    userEmailController.text = userEmail ?? '';
    userIdController.text = userId ?? '';
  }

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

  Future<void> _insertServiceDesk(String serviceProblem) async {
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

      final response = await http.post(
        Uri.parse(
            ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.userServiceDesk),
        body: jsonEncode({
          'serviceProblem': serviceProblem,
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
          content:
              Text('Error inserting service desk. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
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
                'Type Of Problem',
                servicesProblemController,
                servicesProblemFocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your problem';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'User Email',
                userEmailController,
                userEmailFocusNode,
                TextInputType.text,
                isDisabled: true,
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'User Id',
                userIdController,
                userIdFocusNode,
                TextInputType.text,
                isDisabled: true,
              ),
              SizedBox(height: 10),
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
                        _insertServiceDesk(servicesProblemController.text);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(HexColor('#9AD0D3')),
                    ),
                    child: Text(
                      'Submit Service Desk',
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

class ServiceDeskHistory {
  String title;
  String serviceId;
  String serviceProblem;
  String serviceStatus;
  String serviceNote;
  bool isExpanded;

  ServiceDeskHistory(
    this.title,
    this.serviceId,
    this.serviceProblem,
    this.serviceStatus,
    this.serviceNote,
  ) : isExpanded = false;
}

class ServiceHistoryWidget extends StatefulWidget {
  const ServiceHistoryWidget({Key? key}) : super(key: key);

  @override
  _ServiceHistoryWidgetState createState() => _ServiceHistoryWidgetState();
}

class _ServiceHistoryWidgetState extends State<ServiceHistoryWidget> {
  Future<List<ServiceDeskHistory>>? _servicesFuture;
  late TextEditingController _searchController;
  List<ServiceDeskHistory> _services = [];

  @override
  void initState() {
    super.initState();
    _servicesFuture = _getUserLeaves();
    _searchController = TextEditingController();
  }

  Future<List<ServiceDeskHistory>> _getUserLeaves() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userServiceDesk}?staffId=$userid'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        List<dynamic> responseBody = jsonDecode(response.body);

        _services = responseBody.map<ServiceDeskHistory>((item) {
          DateTime serviceApply = DateFormat('EEE, dd MMM yyyy HH:mm:ss')
              .parse(item['serviceDate']);
          String formattedDate = DateFormat('d MMMM yyyy').format(serviceApply);

          return ServiceDeskHistory(
            formattedDate,
            item['serviceId'].toString(),
            item['serviceProblem'],
            item['serviceStatus'],
            item['serviceNote'],
          );
        }).toList();
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No Service Desk found. Please try again later.'),
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
    return _services;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: FutureBuilder<List<ServiceDeskHistory>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            _services = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildSearchInput(),
                    _renderSteps(_filterClaims(_services)),
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
          labelText: 'Filter Service Desk',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  List<ServiceDeskHistory> _filterClaims(List<ServiceDeskHistory> services) {
    if (_searchController.text.isEmpty) {
      return services;
    } else {
      String query = _searchController.text.toLowerCase();
      return services.where((services) {
        return services.serviceProblem.toLowerCase().contains(query) ||
            services.serviceStatus.toLowerCase().contains(query) ||
            services.serviceNote.toLowerCase().contains(query) ||
            services.title.toLowerCase().contains(query) ||
            services.serviceId.toLowerCase().contains(query) ||
            services.serviceId.toLowerCase().contains(query);
      }).toList();
    }
  }

  Widget _renderSteps(List<ServiceDeskHistory> services) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            services[index].isExpanded = !services[index].isExpanded;
          });
        },
        children: services.map<ExpansionPanel>((ServiceDeskHistory services) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(services.title,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    if (services.serviceStatus == 'pending')
                      Image.asset('assets/icon/clock.png',
                          width: 24.0, height: 24.0),
                    if (services.serviceStatus == 'done')
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
                  Text('Service Id',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text("# ${services.serviceId}",
                      style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Service Problem',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(services.serviceProblem, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Service Status',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(services.serviceStatus, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Service Note',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(services.serviceNote, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            isExpanded: services.isExpanded,
            canTapOnHeader: true,
          );
        }).toList(),
      ),
    );
  }
}
