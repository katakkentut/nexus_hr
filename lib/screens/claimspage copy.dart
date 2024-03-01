// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:nexus_hr/forms/button.dart';
import 'package:nexus_hr/forms/form.dart';

class ClaimPageWidget extends StatefulWidget {
  const ClaimPageWidget({Key? key}) : super(key: key);

  @override
  State<ClaimPageWidget> createState() => _ClaimPageWidgetState();
}

class _ClaimPageWidgetState extends State<ClaimPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController claimsGroupNameController = TextEditingController();
  TextEditingController claimNameController = TextEditingController();
  TextEditingController receiptNoController = TextEditingController();
  TextEditingController receiptAmountController = TextEditingController();
  FocusNode claimsGroupFocusNode = FocusNode();
  FocusNode claimFocusNode = FocusNode();
  FocusNode receiptNoFocusNode = FocusNode();
  FocusNode receiptAmountFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  late double screenWidth = 0.0;
  late double screenHeight = 0.0;
  File? _image;
  final ImagePicker _picker = ImagePicker();

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
              'Claim Page',
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
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                child: Container(
                  padding: EdgeInsets.all(20),
                  height: screenHeight * 0.86,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FormWidget.buildInput(
                            'Claims Group Name',
                            claimsGroupNameController,
                            claimsGroupFocusNode,
                            TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          FormWidget.buildInput(
                            'Claims Name',
                            claimNameController,
                            claimFocusNode,
                            TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          FormWidget.buildInput(
                            'Receipt No',
                            receiptNoController,
                            receiptNoFocusNode,
                            TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the receipt number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          FormWidget.buildInput(
                            'Receipt Amount',
                            receiptAmountController,
                            receiptAmountFocusNode,
                            TextInputType.number,
                            prefixText: 'RM ',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the receipt amount';
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
                                    print('Form is valid. Submitting...');
                                    print(
                                        'Claims Group Name: ${claimsGroupNameController.text}');
                                    print(
                                        'Claims Name: ${claimNameController.text}');
                                    print(
                                        'Receipt No: ${receiptNoController.text}');
                                    print(
                                        'Receipt Amount: ${receiptAmountController.text}');
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      HexColor('#9AD0D3')),
                                ),
                                child: Text(
                                  'Submit Claim',
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
                ),
              ),
            ],
          ),
        ),
      );
    });
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
