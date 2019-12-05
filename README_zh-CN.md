[English](./README.md) | 简体中文

# Flutter Rebound

[![pub package](https://img.shields.io/pub/v/flutter_rebound.svg)](https://pub.dartlang.org/packages/flutter_rebound)

一个Flutter库，模拟弹簧动力学，并添加现实世界的物理到您的应用程序。

<div align=left>
<img src="https://github.com/flutter-studio/rebound/blob/master/SVID_20191205_120702_1.gif" width = "280"  alt="图片名称" align=center />
  </div>


## 使用
要使用此插件包,请将`flutter_rebound`作为依赖项添加到您的`pubspec.yaml`文件中,详见[dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).


## 示例

``` dart
// 引入包
import 'package:rk4/rk4.dart';
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
    spring = system.createSpring(40, 3);
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
