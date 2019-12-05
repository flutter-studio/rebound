English | [简体中文](./README_zh-CN.md)

# Flutter Rebound

[![pub package](https://img.shields.io/pub/v/flutter_rebound.svg)](https://pub.dartlang.org/packages/flutter_rebound)

A Flutter library that models spring dynamics and adds real world physics to your app. inspired by Facebook [Rebound](https://github.com/facebook/rebound)

## Usage
To use this plugin, add `flutter_rebound` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).


## Example

``` dart
// Import package
import 'package:rebound/rebound.dart';
import 'package:flutter/material.dart';
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  SpringSystem system;
  Spring spring;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    system = SpringSystem(vsync: this);
    spring =
        system.createSpringWithConfig(SpringConfig(tension: 40, friction: 3));
    spring.addUpdateListener((spring) {
      double value = spring.currentValue;
      _scale = 1 - value * 0.5;
      setState(() {});
    });
    spring.endValue = 1;
  }

  @override
  void dispose() {
    system.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Transform.scale(
          scale: _scale,
          child: Container(
            width: 200,
            height: 200,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
```

