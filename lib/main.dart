import 'package:flutter/material.dart';
import 'package:hrm_app/screens/splash_screen.dart';
import 'constants/global_keys.dart';

void main() {
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: MyGlobalKeys.navigatorKey,
        home: splash_screen(),
      );
  }
}


