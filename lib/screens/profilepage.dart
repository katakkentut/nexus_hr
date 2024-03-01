// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nexus_hr/forms/form.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nexus_hr/utils/api-endpoint.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({Key? key}) : super(key: key);

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0; // To keep track of the selected index

  late double screenWidth = 0.0;
  late double screenHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      setState(() {}); // Trigger a rebuild after obtaining screen dimensions
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
              'User Profile',
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
                top: screenHeight * 0.1,
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildNavBarItem(Icons.person, 0),
                    SizedBox(width: screenWidth * 0.03),
                    buildNavBarItem(Icons.house, 1),
                    SizedBox(width: screenWidth * 0.03),
                    buildNavBarItem(Icons.phone, 2),
                    SizedBox(width: screenWidth * 0.03),
                    buildNavBarItem(Icons.settings, 3),
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
            child: index == 3
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
        'assets/icon/mortarboard.png',
        width: screenWidth * 0.2,
        height: screenHeight * 0.2,
      ),
    );
  }

  Widget getContentWidget(int index) {
    switch (index) {
      case 0:
        return PersonalDetailWidget();
      case 1:
        return AddressWidget();
      case 2:
        return ContactWidget();
      case 3:
        return EducationBackgroundWidget();
      default:
        return Container();
    }
  }

  String getContent(int index) {
    String title = '';
    switch (index) {
      case 0:
        title = 'Personal Detail';
        break;
      case 1:
        title = 'Address';
        break;
      case 2:
        title = 'Contact';
        break;
      case 3:
        title = 'Education Background';
        break;
      default:
        title = '';
    }
    return title;
  }
}

class PersonalDetailWidget extends StatefulWidget {
  const PersonalDetailWidget({Key? key}) : super(key: key);

  @override
  _PersonalDetailWidgetState createState() => _PersonalDetailWidgetState();
}

class _PersonalDetailWidgetState extends State<PersonalDetailWidget> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController raceController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final FocusNode fullNameFocusNode = FocusNode();
  final FocusNode religionFocusNode = FocusNode();
  final FocusNode raceFocusNode = FocusNode();
  final FocusNode nationalityFocusNode = FocusNode();
  final FocusNode idNumberFocusNode = FocusNode();

  @override
  void dispose() {
    fullNameController.dispose();
    religionController.dispose();
    raceController.dispose();
    nationalityController.dispose();
    idNumberController.dispose();
    fullNameFocusNode.dispose();
    religionFocusNode.dispose();
    raceFocusNode.dispose();
    nationalityFocusNode.dispose();
    idNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getPersonalDetail();
    });
  }

  void _getPersonalDetail() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.personalDetail}?staffId=$userid'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            fullNameController.text = responseData['userFullName'];
            religionController.text = responseData['userReligion'];
            raceController.text = responseData['userRace'];
            nationalityController.text = responseData['userNationality'];
            idNumberController.text = responseData['userId'].toString();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FormWidget.buildInput(
            'Full Name',
            fullNameController,
            fullNameFocusNode,
            TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
            isDisabled: true,
          ),
          SizedBox(height: 10),
          FormWidget.buildInput(
            'Religion',
            religionController,
            religionFocusNode,
            TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your religion';
              }
              return null;
            },
            isDisabled: true,
          ),
          SizedBox(height: 10),
          FormWidget.buildInput(
            'Race',
            raceController,
            raceFocusNode,
            TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your race';
              }
              return null;
            },
            isDisabled: true,
          ),
          SizedBox(height: 10),
          FormWidget.buildInput(
            'Nationality',
            nationalityController,
            nationalityFocusNode,
            TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your Nationality';
              }
              return null;
            },
            isDisabled: true,
          ),
          SizedBox(height: 10),
          FormWidget.buildInput(
            'Id Number',
            idNumberController,
            idNumberFocusNode,
            TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your Id Number';
              }
              return null;
            },
            isDisabled: true,
          ),
        ],
      ),
    );
  }
}

class AddressWidget extends StatefulWidget {
  const AddressWidget({Key? key}) : super(key: key);

  @override
  _AddressWidgetState createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  final TextEditingController address1controller = TextEditingController();
  final TextEditingController address2controller = TextEditingController();
  final TextEditingController citycontroller = TextEditingController();
  final TextEditingController postcodecontroller = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final FocusNode address1FocusNode = FocusNode();
  final FocusNode address2FocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode postcodeFocusNode = FocusNode();
  final FocusNode regionFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    address1controller.dispose();
    address2controller.dispose();
    citycontroller.dispose();
    postcodecontroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAddress();
    });
  }

  void _getAddress() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userAddress}?staffId=$userid'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            address1controller.text = responseData['address1'];
            address2controller.text = responseData['address2'];
            citycontroller.text = responseData['addressCity'];
            postcodecontroller.text =
                responseData['addressPostcode'].toString();
            regionController.text = responseData['addressRegion'];
          });
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address has not yet been updated !'),
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
  }

  Future<void> _updateAddress(String address1, String address2, String city,
      String postcode, String region) async {
    try {
      final storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'accessToken');

      final response = await http.post(
        Uri.parse(
            ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.userAddress),
        body: jsonEncode({
          'address1': address1,
          'address2': address2,
          'city': city,
          'postcode': postcode,
          'region': region,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          _getAddress();
        }
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating address. Please try again later.'),
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
                'Address Line 1',
                address1controller,
                address1FocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address 1';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'Address Line 2',
                address2controller,
                address2FocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address 2';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'City',
                citycontroller,
                cityFocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'Region/State',
                regionController,
                regionFocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your region/state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'Postcode',
                postcodecontroller,
                postcodeFocusNode,
                TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your postcode';
                  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid postcode number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateAddress(
                            address1controller.text,
                            address2controller.text,
                            citycontroller.text,
                            postcodecontroller.text,
                            regionController.text);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(HexColor('#9AD0D3')),
                    ),
                    child: Text(
                      'Update Address',
                      style: GoogleFonts.roboto(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactWidget extends StatefulWidget {
  const ContactWidget({Key? key}) : super(key: key);

  @override
  _ContactWidgetState createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emergencyContactNameController =
      TextEditingController();
  final TextEditingController emergencyContactNumberController =
      TextEditingController();
  final TextEditingController relationshipController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneNumberFocusNode = FocusNode();
  final FocusNode emergencyContactNameFocusNode = FocusNode();
  final FocusNode emergencyContactNumberFocusNode = FocusNode();
  final FocusNode relationshipFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    phoneNumberController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactNumberController.dispose();
    relationshipController.dispose();
    emailFocusNode.dispose();
    phoneNumberFocusNode.dispose();
    emergencyContactNameFocusNode.dispose();
    emergencyContactNumberFocusNode.dispose();
    relationshipFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getContactInformation();
    });
  }

  void _getContactInformation() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userContact}?staffId=$userid'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            emailController.text = responseData['userEmail'];
            phoneNumberController.text = responseData['userPhone'];
            emergencyContactNameController.text = responseData['emergencyName'];
            emergencyContactNumberController.text =
                responseData['emergencyPhone'];
            relationshipController.text = responseData['emergencyRelay'];
          });
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact Information has not yet been updated !'),
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
  }

  Future<void> _updateContactInformation(
      String email,
      String phoneNumber,
      String emergencyName,
      String emergencyNumber,
      String emergencyRelay) async {
    try {
      final storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'accessToken');

      final response = await http.post(
        Uri.parse(
            ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.userContact),
        body: jsonEncode({
          'userEmail': email,
          'userPhone': phoneNumber,
          'emergencyName': emergencyName,
          'emergencyPhone': emergencyNumber,
          'emergencyRelation': emergencyRelay,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          final storage = FlutterSecureStorage();
          await storage.write(key: 'userEmail', value: email);
          _getContactInformation();
        }
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating address. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FormWidget.buildInput(
                  'Email Address',
                  emailController,
                  emailFocusNode,
                  TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your emergency contact name';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                FormWidget.buildInput(
                  'Phone Number',
                  phoneNumberController,
                  phoneNumberFocusNode,
                  TextInputType.number,
                  prefixText: "+60 ",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                FormWidget.buildInput(
                  'Emergency Contact Name',
                  emergencyContactNameController,
                  emergencyContactNameFocusNode,
                  TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your emergency contact name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                FormWidget.buildInput(
                  'Emergency Contact Number',
                  emergencyContactNumberController,
                  emergencyContactNumberFocusNode,
                  TextInputType.number,
                  prefixText: "+60 ",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                FormWidget.buildInput(
                  'Relationship',
                  relationshipController,
                  relationshipFocusNode,
                  TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your relationship';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateContactInformation(
                              emailController.text,
                              phoneNumberController.text,
                              emergencyContactNameController.text,
                              emergencyContactNumberController.text,
                              relationshipController.text);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(HexColor('#9AD0D3')),
                      ),
                      child: Text(
                        'Update Profile',
                        style: GoogleFonts.roboto(
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 150),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EducationBackgroundWidget extends StatefulWidget {
  const EducationBackgroundWidget({Key? key}) : super(key: key);

  @override
  _EducationBackgroundWidgetState createState() =>
      _EducationBackgroundWidgetState();
}

class _EducationBackgroundWidgetState extends State<EducationBackgroundWidget> {
  final TextEditingController highestEducationLevelController =
      TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController yearOfGraduationController =
      TextEditingController();
  final TextEditingController resultController = TextEditingController();
  final FocusNode highestEducationLevelFocusNode = FocusNode();
  final FocusNode universityFocusNode = FocusNode();
  final FocusNode yearOfGraduationFocusNode = FocusNode();
  final FocusNode resultFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  dynamic _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    highestEducationLevelController.dispose();
    universityController.dispose();
    yearOfGraduationController.dispose();
    resultController.dispose();
    highestEducationLevelFocusNode.dispose();
    universityFocusNode.dispose();
    yearOfGraduationFocusNode.dispose();
    resultFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserEducation();
    });
  }

  void _getUserEducation() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userEducation}?staffId=$userid'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            highestEducationLevelController.text =
                responseData['userEducation'];
            universityController.text = responseData['userUniversity'];
            yearOfGraduationController.text =
                responseData['userYear'].toString();
            resultController.text = responseData['userResult'];
            if (responseData['educationProof'] != null) {
              _image = ApiEndPoints.baseUrl +
                  ApiEndPoints.authEndpoints.serveEducationAttachment +
                  responseData['educationProof'];
            }
          });
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Education information has not yet been updated !'),
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
  }

  Future<void> _updateUserEducation(
      String highestEducation,
      String educationPlace,
      String yearGraduation,
      String educationResult) async {
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
            ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.userEducation),
        body: jsonEncode({
          'highestEducation': highestEducation,
          'educationPlace': educationPlace,
          'yearGraduation': yearGraduation,
          'educationResult': educationResult,
          'attachment': attachment,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          _getUserEducation();
        }
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating address. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                'Highest Education Level',
                highestEducationLevelController,
                highestEducationLevelFocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your highest education level';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'University/College/Institution/School',
                universityController,
                universityFocusNode,
                TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your university/college/institution/school';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'Year of Graduation',
                yearOfGraduationController,
                yearOfGraduationFocusNode,
                TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your year of graduation';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              FormWidget.buildInput(
                'Result (CGPA/Grade/Class)',
                resultController,
                resultFocusNode,
                TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your result';
                  }
                  return null;
                },
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
                        _updateUserEducation(
                            highestEducationLevelController.text,
                            universityController.text,
                            yearOfGraduationController.text,
                            resultController.text);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(HexColor('#9AD0D3')),
                    ),
                    child: Text(
                      'Update Profile',
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
              width: double.infinity,
              height: 200,
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
                  : _image is File
                      ? Image.file(
                          _image,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          _image,
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
