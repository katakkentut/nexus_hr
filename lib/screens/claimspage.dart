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
import 'package:nexus_hr/forms/dropdownform.dart';
import 'package:nexus_hr/forms/form.dart';
import 'package:nexus_hr/utils/api-endpoint.dart';

class ClaimPageWidget extends StatefulWidget {
  const ClaimPageWidget({Key? key}) : super(key: key);

  @override
  State<ClaimPageWidget> createState() => _ClaimPageWidgetState();
}

class _ClaimPageWidgetState extends State<ClaimPageWidget> {
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
        'assets/icon/refund.png',
        width: screenWidth * 0.12,
        height: screenHeight * 0.12,
      ),
    );
  }

  Widget getContentWidget(int index) {
    switch (index) {
      case 0:
        return ClaimWidget();
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
        title = 'Claim';
        break;
      case 1:
        title = 'Claim History';
        break;
      default:
        title = '';
    }
    return title;
  }
}

class ClaimWidget extends StatefulWidget {
  const ClaimWidget({Key? key}) : super(key: key);

  @override
  _ClaimWidgetState createState() => _ClaimWidgetState();
}

class _ClaimWidgetState extends State<ClaimWidget> {
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

  @override
  void dispose() {
    claimsGroupNameController.dispose();
    claimNameController.dispose();
    receiptNoController.dispose();
    receiptAmountController.dispose();
    claimsGroupFocusNode.dispose();
    claimFocusNode.dispose();
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

  Future<void> _insertClaim(String claimGroupName, String claimName,
      String receiptNo, String receiptAmount) async {
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
        Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.userClaim),
        body: jsonEncode({
          'claimGroupName': claimGroupName,
          'claimName': claimName,
          'receiptNo': receiptNo,
          'receiptAmount': receiptAmount,
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
          content: Text('Error inserting claim. Please try again later.'),
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
              DropDownWidget.buildInput(
                'Claims Group Name',
                claimsGroupNameController,
                claimsGroupFocusNode,
                TextInputType.text,
                dropdownItems: ['Please Select', 'Personal', 'Company'],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the claims group name';
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
                    return 'Please enter your claim name';
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
                        _insertClaim(
                            claimsGroupNameController.text,
                            claimNameController.text,
                            receiptNoController.text,
                            receiptAmountController.text);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(HexColor('#9AD0D3')),
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

class ClaimHistory {
  ClaimHistory(this.title, this.claimId, this.userId, this.claimGroupName,
      this.claimName, this.receiptNo, this.receiptAmount, this.claimStatus,
      [this.isExpanded = false]);
  String title;
  String claimId;
  String userId;
  String claimGroupName;
  String claimName;
  String receiptNo;
  String receiptAmount;
  String claimStatus;
  bool isExpanded;
}

class ClaimHistoryWidget extends StatefulWidget {
  const ClaimHistoryWidget({Key? key}) : super(key: key);

  @override
  _ClaimHistoryWidgetState createState() => _ClaimHistoryWidgetState();
}

class _ClaimHistoryWidgetState extends State<ClaimHistoryWidget> {
  Future<List<ClaimHistory>>? _claimsFuture;
  List<ClaimHistory> _claims = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _claimsFuture = _getUserEducation();
    _searchController = TextEditingController();
  }

  Future<List<ClaimHistory>> _getUserEducation() async {
    List<ClaimHistory> _claims = [];
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final userid = await storage.read(key: 'userid');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            '${ApiEndPoints.baseUrl}${ApiEndPoints.authEndpoints.userClaim}?staffId=$userid'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        List<dynamic> responseBody = jsonDecode(response.body);

        _claims = responseBody.map<ClaimHistory>((item) {
          DateTime parsedDate =
              DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(item['claimDate']);
          String formattedDate = DateFormat('d MMMM yyyy').format(parsedDate);
          return ClaimHistory(
            formattedDate,
            item['claimId'].toString(),
            item['userId'].toString(),
            item['claimGroupName'],
            item['claimName'],
            item['claimReceiptNo'].toString(),
            item['claimAmount'].toString(),
            item['claimStatus'],
          );
        }).toList();
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
    return _claims;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: FutureBuilder<List<ClaimHistory>>(
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
          labelText: 'Filter Claims',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  List<ClaimHistory> _filterClaims(List<ClaimHistory> claims) {
    if (_searchController.text.isEmpty) {
      return claims;
    } else {
      String query = _searchController.text.toLowerCase();
      return claims.where((claim) {
        return claim.title.toLowerCase().contains(query) ||
            claim.claimId.toLowerCase().contains(query) ||
            claim.userId.toLowerCase().contains(query) ||
            claim.claimGroupName.toLowerCase().contains(query) ||
            claim.claimName.toLowerCase().contains(query) ||
            claim.receiptNo.toLowerCase().contains(query) ||
            claim.receiptAmount.toLowerCase().contains(query) ||
            claim.claimStatus.toLowerCase().contains(query);
      }).toList();
    }
  }

  Widget _renderSteps(List<ClaimHistory> claims) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            claims[index].isExpanded = !claims[index].isExpanded;
          });
        },
        children: claims.map<ExpansionPanel>((ClaimHistory claim) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(claim.title,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    if (claim.claimStatus == 'pending')
                      Image.asset('assets/icon/clock.png',
                          width: 24.0, height: 24.0),
                    if (claim.claimStatus == 'rejected')
                      Image.asset('assets/icon/reject.png',
                          width: 24.0, height: 24.0),
                    if (claim.claimStatus == 'approved')
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
                  Text('Claim Id',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text("# ${claim.claimId}", style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Claim Group Name',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(claim.claimGroupName, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Claim Name',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(claim.claimName, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Receipt No',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(claim.receiptNo, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Receipt Amount',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text("RM ${claim.receiptAmount}",
                      style: TextStyle(fontSize: 12)),
                  SizedBox(height: 10),
                  Text('Claim Status',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(claim.claimStatus, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            isExpanded: claim.isExpanded,
            canTapOnHeader: true,
          );
        }).toList(),
      ),
    );
  }
}
