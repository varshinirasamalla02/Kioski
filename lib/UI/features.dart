import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

class Features extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FeaturesState();
  }
}

class _FeaturesState extends State<Features> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Features',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}