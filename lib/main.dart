import 'package:flutter/material.dart';
import 'view/home_page.dart';
import 'view/event_list_page.dart'; // Add this line

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => const HomePage(), // Home Page route
        '/event-list': (context) => const EventListPage(), // Event List Page route
      },
    );
  }
}
