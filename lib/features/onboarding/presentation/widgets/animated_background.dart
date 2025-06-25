import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final Color primaryColor;
  final Color secondaryColor;

  const AnimatedBackground({
    super.key,
    required this.controller,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(
            animation: controller.value,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;

  _BackgroundPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Background gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withOpacity(0.05),
        secondaryColor.withOpacity(0.05),
        Colors.white,
      ],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Animated circles
    for (int i = 0; i < 5; i++) {
      final progress = (animation + i * 0.2) % 1.0;
      final opacity = (1.0 - progress) * 0.1;

      paint.shader = null;
      paint.color = i.isEven
          ? primaryColor.withOpacity(opacity)
          : secondaryColor.withOpacity(opacity);

      final radius = size.width * 0.3 * progress;
      final center = Offset(
        size.width * (0.2 + i * 0.2),
        size.height * (0.3 + math.sin(animation * 2 * math.pi + i) * 0.1),
      );

      canvas.drawCircle(center, radius, paint);
    }

    // Animated wave
    final wavePath = Path();
    wavePath.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.85 +
          math.sin((x / size.width + animation) * 2 * math.pi) * 20;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    paint.color = primaryColor.withOpacity(0.05);
    canvas.drawPath(wavePath, paint);

    // Additional floating bubbles
    for (int i = 0; i < 3; i++) {
      final bubbleProgress = (animation + i * 0.33) % 1.0;
      final bubbleY = size.height * (1 - bubbleProgress);
      final bubbleX = size.width * (0.25 + i * 0.25) +
          math.sin(bubbleProgress * math.pi * 2) * 30;

      paint.color = i.isEven
          ? primaryColor.withOpacity(0.1 * (1 - bubbleProgress))
          : secondaryColor.withOpacity(0.1 * (1 - bubbleProgress));

      canvas.drawCircle(
        Offset(bubbleX, bubbleY),
        20 * (1 + bubbleProgress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        primaryColor != oldDelegate.primaryColor ||
        secondaryColor != oldDelegate.secondaryColor;
  }
}