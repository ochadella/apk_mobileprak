import 'dart:math';
import 'package:flutter/material.dart';

/// Wordmark "BABOY" dengan tiap huruf goyang naik-turun bergantian
/// (efek "joget"), looping terus. Warnanya bisa disesuaikan.
class BaboyWordmark extends StatefulWidget {
  final double fontSize;
  final Color color;

  const BaboyWordmark({
    super.key,
    this.fontSize = 44,
    this.color = const Color(0xFF4A3524),
  });

  @override
  State<BaboyWordmark> createState() => _BaboyWordmarkState();
}

class _BaboyWordmarkState extends State<BaboyWordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const String _text = 'BABOY';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_text.length, (i) {
            // Tiap huruf punya fase beda, jadi goyangnya bergelombang
            final phase = _controller.value * 2 * pi + (i * 0.9);
            final offsetY = sin(phase) * (widget.fontSize * 0.09);

            return Transform.translate(
              offset: Offset(0, offsetY),
              child: Text(
                _text[i],
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w900,
                  color: widget.color,
                  letterSpacing: 1,
                  height: 1,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
