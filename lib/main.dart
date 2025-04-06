import 'package:flutter/material.dart';
import 'package:flutter_dummy_json_recipes/screens/homescreen.dart';
import 'package:flutter_dummy_json_recipes/screens/tagsscreen.dart';
import 'package:is_wear/is_wear.dart';
import 'package:wear_plus/wear_plus.dart';

final _isWearPlugin = IsWear();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  bool isWear = await _isWearPlugin.check()??false;
  runApp( MyApp(isWear: isWear,));

}

class MyApp extends StatelessWidget {
  final bool isWear;
  const MyApp({super.key, required this.isWear});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isWear? Tagsscreen() : Homescreen(),
    );
  }
}

