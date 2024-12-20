import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'view/home_page.dart';
import 'view/login_page.dart';
import 'view/signup_page.dart';
import 'services/notification_service.dart';


final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: '/login', 
      routes: {
        '/login': (context) =>  LoginPage(),
        '/signup': (context) =>  SignupPage(),
        '/': (context) => StreamBuilder(
          stream: authController.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasData) {
              return const HomePage(); 
            }

            return LoginPage(); 
          },
        ),
      },
    );
  }
}