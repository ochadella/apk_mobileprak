import 'package:flutter/material.dart';

/// Mascot "Baboy" versi monyet — muka coklat, kuping di SAMPING (bukan
/// di atas kayak beruang), mata besar, pipi blush. Dibikin dari shape
/// dasar + 1 CustomPainter kecil buat senyumnya.
class MonkeyMascot extends StatelessWidget {
  final double size;
  final Color furColor;
  final Color earInnerColor;
  final Color blushColor;

  const MonkeyMascot({
    super.key,
    this.size = 100,
    this.furColor = const Color(0xFF9C6B45),
    this.earInnerColor = const Color(0xFFE8CBA6),
    this.blushColor = const Color(0xFFF4A9C0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.32,
      height: size * 1.05,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Kuping kiri — ditaruh di SAMPING (sejajar tengah wajah),
          // sebagian nempel di belakang muka, biar keliatan kuping monyet
          // bukan kuping beruang yang nongol di atas kepala.
          Positioned(
            left: 0,
            top: size * 0.34,
            child: _Ear(size: size * 0.4, outer: furColor, inner: earInnerColor),
          ),
          Positioned(
            right: 0,
            top: size * 0.34,
            child: _Ear(size: size * 0.4, outer: furColor, inner: earInnerColor),
          ),
          // Muka (digambar setelah kuping, jadi nutupin sebagian
          // pangkal kuping — efeknya kuping keliatan "nempel" di sisi muka)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: furColor, shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pipi blush kiri
                Positioned(
                  left: size * 0.03,
                  top: size * 0.58,
                  child: _Blush(width: size * 0.2, height: size * 0.13, color: blushColor),
                ),
                // Pipi blush kanan
                Positioned(
                  right: size * 0.03,
                  top: size * 0.58,
                  child: _Blush(width: size * 0.2, height: size * 0.13, color: blushColor),
                ),
                // Mata
                Positioned(
                  top: size * 0.3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Eye(size: size * 0.24),
                      SizedBox(width: size * 0.1),
                      _Eye(size: size * 0.24),
                    ],
                  ),
                ),
                // Senyum
                Positioned(
                  top: size * 0.6,
                  child: SizedBox(
                    width: size * 0.34,
                    height: size * 0.16,
                    child: CustomPaint(painter: _SmilePainter()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ear extends StatelessWidget {
  final double size;
  final Color outer;
  final Color inner;
  const _Ear({required this.size, required this.outer, required this.inner});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: outer, shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(color: inner, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  final double size;
  const _Eye({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: size * 0.52,
          height: size * 0.52,
          decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _Blush extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  const _Blush({required this.width, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.75),
        borderRadius: BorderRadius.circular(width),
      ),
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.32
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SmilePainter oldDelegate) => false;
}
