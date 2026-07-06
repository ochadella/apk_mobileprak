import 'package:flutter/material.dart';

/// Background krem dengan lingkaran-lingkaran dekoratif, dipakai di
/// Splash & Login (halaman yang sengaja "fixed theme", gak ikut dark mode,
/// sama kayak splash sebelumnya yang emang selalu gradient biru).
class CreamCircleBackground extends StatelessWidget {
  final Widget child;

  const CreamCircleBackground({super.key, required this.child});

  static const Color bgColor = Color(0xFFF3E5D0);
  static const Color circleLight = Color(0xFFEAD9BB);
  static const Color circleDark = Color(0xFFDDC29B);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgColor,
      child: Stack(
        children: [
          Positioned(top: -50, left: -40, child: _circle(140, circleLight)),
          Positioned(top: 80, right: -60, child: _circle(170, circleDark)),
          Positioned(bottom: -70, left: -50, child: _circle(190, circleLight)),
          Positioned(bottom: 60, right: -30, child: _circle(110, circleDark)),
          Positioned(top: 260, left: 20, child: _circle(60, circleLight)),
          child,
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

