import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:media_player/ui/router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: 'Media Player',
      theme: NeumorphicThemeData(),
      onGenerateRoute: Router.generateRoute,
      initialRoute: homeRoute,
    );
  }
}
