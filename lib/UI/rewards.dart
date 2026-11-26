import 'package:flutter/material.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

// ignore: use_key_in_widget_constructors
class Rewards extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RewardsState();
  }
}

class _RewardsState extends State<Rewards> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Rewards',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}