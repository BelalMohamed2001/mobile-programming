import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'view/home_page.dart';
import 'view/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: StreamBuilder(
        stream: authController.authState,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const HomePage(); // Redirect to Home if authenticated
          }
          return  LoginPage(); // Redirect to Login if not authenticated
        },
      ),
    );
  }
}
