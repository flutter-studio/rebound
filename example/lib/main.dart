import 'package:flutter/material.dart';
import 'package:flutter_rebound/flutter_rebound.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

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
    spring = system.createSpring(tension: 40, friction: 3);
    spring.addUpdateListener((spring) {
      double value = spring.currentValue;
      _scale = mapValueFromRangeToRange(value, 0, -1, 1, 0.5);
      setState(() {});
    });
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
        child: GestureDetector(
          onTapDown: (e) {
            spring.endValue = -1;
          },
          onTapUp: (_) {
            spring.endValue = 0;
          },
          child: Transform.scale(
            scale: _scale,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

double mapValueFromRangeToRange(
  value,
  fromLow,
  fromHigh,
  toLow,
  toHigh,
) {
  var fromRangeSize = fromHigh - fromLow;
  var toRangeSize = toHigh - toLow;
  var valueScale = (value - fromLow) / fromRangeSize;
  return toLow + valueScale * toRangeSize;
}
