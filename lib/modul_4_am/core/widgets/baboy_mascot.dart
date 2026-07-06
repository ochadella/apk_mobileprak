import 'dart:math';
import 'package:flutter/material.dart';

/// Ekspresi yang tersedia buat mascot Baboy.
enum BaboyExpression { happy, sad, thinking, surprised, sleepy }

/// Mascot "Baboy" — karakter bintang bertopi koboi, digambar langsung
/// pakai CustomPainter (bukan asset gambar), jadi ringan & gampang
/// diubah warnanya. Ganti [expression] buat nyesuain suasana halaman.
class BaboyMascot extends StatelessWidget {
  final double size;
  final BaboyExpression expression;
  final Color starColor;
  final Color accentColor;

  const BaboyMascot({
    super.key,
    this.size = 90,
    this.expression = BaboyExpression.happy,
    this.starColor = const Color(0xFFFBBF24),
    this.accentColor = const Color(0xFF2563EB),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.05,
      height: size * 1.55,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: size * 1.18,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Boot(size: size * 0.34, color: accentColor),
                SizedBox(width: size * 0.14),
                _Boot(size: size * 0.34, color: accentColor),
              ],
            ),
          ),
          Positioned(
            top: size * 0.98,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 2.5, height: size * 0.24, color: Colors.black87),
                SizedBox(width: size * 0.26),
                Container(width: 2.5, height: size * 0.24, color: Colors.black87),
              ],
            ),
          ),
          Positioned(
            top: size * 0.32,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _StarPainter(color: starColor),
                child: Padding(
                  padding: EdgeInsets.only(top: size * 0.08),
                  child: Center(
                    child: SizedBox(
                      width: size * 0.46,
                      height: size * 0.3,
                      child: CustomPaint(
                        painter: _FacePainter(expression: expression),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: SizedBox(
              width: size * 0.85,
              height: size * 0.4,
              child: CustomPaint(
                painter: _HatPainter(color: accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeJoin = StrokeJoin.round;

    final path = _starPath(size);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  Path _starPath(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2 * 0.94;
    final innerR = outerR * 0.42;
    const points = 5;
    const startAngle = -pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = startAngle + (pi / points) * i;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FacePainter extends CustomPainter {
  final BaboyExpression expression;
  _FacePainter({required this.expression});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeY = size.height * 0.28;
    final eyeSpacing = size.width * 0.5;
    final leftX = size.width / 2 - eyeSpacing / 2;
    final rightX = size.width / 2 + eyeSpacing / 2;
    final eyeR = size.width * 0.14;

    switch (expression) {
      case BaboyExpression.happy:
        _hillEye(canvas, linePaint, Offset(leftX, eyeY), eyeR);
        _hillEye(canvas, linePaint, Offset(rightX, eyeY), eyeR);
        final mouth = Path()
          ..moveTo(size.width * 0.5 - size.width * 0.2, size.height * 0.62)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.85,
              size.width * 0.5 + size.width * 0.2, size.height * 0.62);
        canvas.drawPath(mouth, linePaint);
        break;

      case BaboyExpression.sad:
        _valleyEye(canvas, linePaint, Offset(leftX, eyeY), eyeR);
        _valleyEye(canvas, linePaint, Offset(rightX, eyeY), eyeR);
        final mouth = Path()
          ..moveTo(size.width * 0.5 - size.width * 0.16, size.height * 0.78)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.6,
              size.width * 0.5 + size.width * 0.16, size.height * 0.78);
        canvas.drawPath(mouth, linePaint);
        break;

      case BaboyExpression.surprised:
        canvas.drawCircle(Offset(leftX, eyeY), eyeR * 0.65, fillPaint);
        canvas.drawCircle(Offset(rightX, eyeY), eyeR * 0.65, fillPaint);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.72),
            width: size.width * 0.18,
            height: size.height * 0.28,
          ),
          fillPaint,
        );
        break;

      case BaboyExpression.thinking:
        _hillEye(canvas, linePaint, Offset(leftX, eyeY), eyeR);
        canvas.drawCircle(Offset(rightX, eyeY), eyeR * 0.6, fillPaint);
        final mouth = Path()
          ..moveTo(size.width * 0.5 - size.width * 0.1, size.height * 0.68)
          ..lineTo(size.width * 0.5 + size.width * 0.14, size.height * 0.68);
        canvas.drawPath(mouth, linePaint);
        break;

      case BaboyExpression.sleepy:
        final line1 = Path()
          ..moveTo(leftX - eyeR, eyeY)
          ..lineTo(leftX + eyeR, eyeY);
        final line2 = Path()
          ..moveTo(rightX - eyeR, eyeY)
          ..lineTo(rightX + eyeR, eyeY);
        canvas.drawPath(line1, linePaint);
        canvas.drawPath(line2, linePaint);
        final mouth = Path()
          ..moveTo(size.width * 0.5 - size.width * 0.08, size.height * 0.68)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.6,
              size.width * 0.5 + size.width * 0.08, size.height * 0.68);
        canvas.drawPath(mouth, linePaint);
        break;
    }
  }

  void _hillEye(Canvas canvas, Paint paint, Offset center, double r) {
    final rect = Rect.fromCenter(center: center, width: r * 2, height: r * 2);
    canvas.drawArc(rect, pi, pi, false, paint);
  }

  void _valleyEye(Canvas canvas, Paint paint, Offset center, double r) {
    final rect = Rect.fromCenter(center: center, width: r * 2, height: r * 2);
    canvas.drawArc(rect, 0, pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) =>
      oldDelegate.expression != expression;
}

class _HatPainter extends CustomPainter {
  final Color color;
  _HatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025;

    final brimRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.7),
      width: size.width,
      height: size.height * 0.4,
    );
    canvas.drawOval(brimRect, fill);
    canvas.drawOval(brimRect, stroke);

    final crownRect = Rect.fromLTWH(
      size.width * 0.24,
      0,
      size.width * 0.52,
      size.height * 0.72,
    );
    final crownPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        crownRect,
        topLeft: Radius.circular(size.width * 0.22),
        topRight: Radius.circular(size.width * 0.22),
      ));
    canvas.drawPath(crownPath, fill);
    canvas.drawPath(crownPath, stroke);
  }

  @override
  bool shouldRepaint(covariant _HatPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _Boot extends StatelessWidget {
  final double size;
  final Color color;
  const _Boot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(
        painter: _BootPainter(color: color),
      ),
    );
  }
}

class _BootPainter extends CustomPainter {
  final Color color;
  _BootPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    final path = Path()
      ..moveTo(size.width * 0.22, 0)
      ..lineTo(size.width * 0.78, 0)
      ..lineTo(size.width * 0.78, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.9, size.height, size.width * 0.68, size.height)
      ..lineTo(size.width * 0.1, size.height)
      ..quadraticBezierTo(0, size.height * 0.95, 0, size.height * 0.8)
      ..lineTo(size.width * 0.22, size.height * 0.55)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _BootPainter oldDelegate) =>
      oldDelegate.color != color;
}
