// ignore_for_file: file_names

import 'package:flutter/material.dart';

class TempScreen extends StatelessWidget {
  const TempScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        decoration: BoxDecoration(border: Border.all()),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * (0.4),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * (0.4) * (0.05),
                ),
                child: CustomPaint(
                  painter: TopContainerCustomPainter(),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * (0.275),
                    height: MediaQuery.of(context).size.height * (0.13),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                painter: MyCustomPainter(),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * (0.8),
                  height: MediaQuery.of(context).size.height * (0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.blueAccent;
    Path path = Path();
    path.lineTo(size.width * (0.3), 0);
    path.lineTo(size.width * (0.5), size.height * (0.25));
    path.lineTo(size.width * (0.7), 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TopContainerCustomPainter extends CustomPainter {
  TopContainerCustomPainter();
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    paint.strokeWidth = 2.5;

    Path path = Path();
    path.moveTo(size.width * (0.5), 0);
    path.lineTo(size.width, size.height * (0.5));
    path.lineTo(size.width * (0.5), size.height);
    path.lineTo(0, size.height * (0.5));
    path.close();
    /*
     path.lineTo(size.width * (0.3), 0);
    path.lineTo(size.width * (0.5), size.height * (0.25));
    path.lineTo(size.width * (0.7), 0);

     */

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
