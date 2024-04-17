// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:nexus_hr/screens/homepage.dart';
import 'package:nexus_hr/utils/api-endpoint.dart';
import 'dart:convert';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController staffIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController companyCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    staffIdController.dispose();
    passwordController.dispose();
    companyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height ,
              child: Image.asset(
                'assets/background/bg.png',
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 2 - 70),
                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.roboto(
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.w500,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  _buildInputField(Icons.mail, 'Staff Id', staffIdController),
                  SizedBox(height: 10),
                  _buildInputField(
                    Icons.lock,
                    'Password',
                    passwordController,
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  _buildInputField(
                    Icons.house,
                    'Company Code',
                    companyCodeController,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _loginUser(staffIdController.text,
                          passwordController.text, companyCodeController.text);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(HexColor('#9AD0D3')),
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      // Handle Forgot Password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  // Additional space to ensure the input is not hidden by the keyboard
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      IconData icon, String hintText, TextEditingController controller,
      {bool obscureText = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: HexColor('#9AD0D3'),
              shape: BoxShape.circle,
            ),
            child: Icon(icon),
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loginUser(
      String email, String password, String companyCode) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.login),
        body: jsonEncode({
          'staffId': email,
          'password': password,
          'companycode': companyCode,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final storage = FlutterSecureStorage();
        await storage.write(
            key: 'accessToken', value: responseBody['token']);
        await storage.write(
            key: 'userid', value: responseBody['userid'].toString());
        Get.to(() => HomepageWidget());
        
      } else {
        Get.snackbar(
          'Error',
          responseBody['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      print(error);
      Get.snackbar(
        'Error',
        'Invalid email or password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
