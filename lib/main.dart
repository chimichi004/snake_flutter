/// Link https://youtu.be/xreBGVmOHrY
/// Thanks to  "A Day Code" for this tutorial.

import 'package:flutter/material.dart';

import 'snakegame.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SnakeGame(),
    );
  }
}
