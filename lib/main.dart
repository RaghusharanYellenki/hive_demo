import 'package:flutter/material.dart';
import 'package:raghusharan/models/person.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/info_screen.dart';

Future<void> main() async {

  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  await Hive.openBox('peopleBox');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'raghusharan',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      debugShowCheckedModeBanner: false,
      home: InfoScreen(),
    );
  }
}
