import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:managment/data/model/add_date.dart';
import 'Screens/login.dart'; // Import the login page
import 'widgets/bottomnavigationbar.dart'; // Ensure this points to the correct file

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AdddataAdapter());
  await Hive.openBox<Add_data>('data');

  // Check if the user is authenticated
  final box = Hive.box<Add_data>('data');
  final token = box.get('token'); // Replace with your logic to retrieve the token

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const Bottom() : Bottom(),
    );
  }
}
