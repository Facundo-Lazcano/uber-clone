part of 'custom_markers.dart';

class MarkerDestinoPainter extends CustomPainter {
  final String description;
  final double metters;

  MarkerDestinoPainter(this.description, this.metters);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()..color = Colors.black;

    canvas.drawCircle(Offset(20, size.height - 20), 20, paint);

    paint.color = Colors.white;
    canvas.drawCircle(Offset(20, size.height - 20), 7, paint);

    // sombra
    final Path path = new Path();
    path.moveTo(0, 20);
    path.lineTo(size.width - 10, 20);
    path.lineTo(size.width - 10, 100);
    path.lineTo(0, 100);

    canvas.drawShadow(path, Colors.black87, 10, false);

    // caja blanca
    final cajaBlanca = Rect.fromLTWH(0, 20, size.width - 10, 80);

    canvas.drawRect(cajaBlanca, paint);

    // caja negra
    paint.color = Colors.black;
    final cajaNegra = Rect.fromLTWH(0, 20, 70, 80);

    canvas.drawRect(cajaNegra, paint);

    // Dibujar textos
    double kilometros = metters / 1000;
    kilometros = kilometros * 100.floor().toDouble();
    kilometros = kilometros / 100;
    TextSpan textSpan = new TextSpan(
        style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
        text: '$kilometros');

    TextPainter textPainter = new TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout(minWidth: 70, maxWidth: 70);
    textPainter.paint(canvas, Offset(0, 35));

    // Km
    textSpan = new TextSpan(
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400),
        text: 'Km');

    textPainter = new TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout(maxWidth: 80);
    textPainter.paint(canvas, Offset(20, 67));

    // Mi ubicacion
    textSpan = new TextSpan(
        style: TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.w400),
        text: '$description');

    textPainter = new TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        maxLines: 2,
        ellipsis: '...')
      ..layout(maxWidth: size.width - 100);
    textPainter.paint(canvas, Offset(80, 35));
  }

  @override
  bool shouldRepaint(MarkerDestinoPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(MarkerDestinoPainter oldDelegate) => false;
}
