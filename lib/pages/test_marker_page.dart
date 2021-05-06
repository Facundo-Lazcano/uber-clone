import 'package:flutter/material.dart';
import 'package:mapas_app/custom_markers/custom_markers.dart';

class TestMarkerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          height: 150,
          color: Colors.red,
          child: CustomPaint(
            painter: MarkerDestinoPainter(
                "Descripcion de un lugar que se encuentra en la casa de tu querida hermana",
                20000),
          ),
        ),
      ),
    );
  }
}
