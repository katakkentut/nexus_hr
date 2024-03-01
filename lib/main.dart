import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:nexus_hr/screens/auth/signin.dart';
import 'package:nexus_hr/screens/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FaceCamera.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data ?? false ? HomepageWidget() : SignInWidget();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

Future<bool> checkLoginStatus() async {
  const storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'accessToken');
  return accessToken != null;
}
