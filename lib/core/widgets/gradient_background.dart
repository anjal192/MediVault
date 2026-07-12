import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BackgroundStyle {
  glowingOrbs,
  medicalCross,
  heartBeat,
  pillPattern,
  aiStars,
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  final BackgroundStyle style;
  final String? backgroundImage;

  const GradientBackground({
    Key? key,
    required this.child,
    this.style = BackgroundStyle.glowingOrbs,
    this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Unified medium-dark marine blue gradient — same across ALL pages
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF091A30), // Deep marine blue
                Color(0xFF0E2040), // Mid marine blue
                Color(0xFF162B50), // Lighter marine blue (right-bottom)
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Background Image Asset
        Positioned.fill(
          child: Opacity(
            opacity: backgroundImage != null ? 0.30 : (isDark ? 0.07 : 0.03), // 20-30% opacity for stethoscope / premium assets
            child: Image.asset(
              backgroundImage ?? 'assets/images/medical_background.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Custom Painter for premium dynamic illustrations
        Positioned.fill(
          child: CustomPaint(
            painter: BackgroundPainter(
              style: style,
              isDark: isDark,
            ),
          ),
        ),
        
        // Content child
        Positioned.fill(
          child: SafeArea(
            child: child,
          ),
        ),
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final BackgroundStyle style;
  final bool isDark;

  BackgroundPainter({required this.style, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final primary = AppTheme.primaryGreen.withAlpha(isDark ? 30 : 20);
    final secondary = AppTheme.accentBlue.withAlpha(isDark ? 25 : 15);

    switch (style) {
      case BackgroundStyle.glowingOrbs:
        _drawOrbs(canvas, size, paint, primary, secondary);
        break;
      case BackgroundStyle.medicalCross:
        _drawMedicalCrosses(canvas, size, paint, primary, secondary);
        break;
      case BackgroundStyle.heartBeat:
        _drawHeartBeatLine(canvas, size, paint, primary, secondary);
        break;
      case BackgroundStyle.pillPattern:
        _drawPillPatterns(canvas, size, paint, primary, secondary);
        break;
      case BackgroundStyle.aiStars:
        _drawAIStars(canvas, size, paint, primary, secondary);
        break;
    }
  }

  void _drawOrbs(Canvas canvas, Size size, Paint paint, Color primary, Color secondary) {
    // Large top-left orb
    paint.shader = RadialGradient(
      colors: [primary, Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(0, 0), radius: size.width * 0.7));
    canvas.drawCircle(Offset(0, 0), size.width * 0.7, paint);

    // Large bottom-right orb
    paint.shader = RadialGradient(
      colors: [secondary, Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.8));
    canvas.drawCircle(Offset(size.width, size.height), size.width * 0.8, paint);
  }

  void _drawMedicalCrosses(Canvas canvas, Size size, Paint paint, Color primary, Color secondary) {
    _drawOrbs(canvas, size, paint, primary, secondary);
    
    final linePaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.20)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw grid of subtle medical crosses in upper-right
    final double step = 60.0;
    final double crossSize = 12.0;
    final double startX = size.width - 200;
    final double startY = 100.0;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final x = startX + i * step;
        final y = startY + j * step;
        
        // Draw cross lines
        canvas.drawLine(Offset(x - crossSize / 2, y), Offset(x + crossSize / 2, y), linePaint);
        canvas.drawLine(Offset(x, y - crossSize / 2), Offset(x, y + crossSize / 2), linePaint);
      }
    }
  }

  void _drawHeartBeatLine(Canvas canvas, Size size, Paint paint, Color primary, Color secondary) {
    _drawOrbs(canvas, size, paint, primary, secondary);

    final pulsePaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.25)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final midY = size.height * 0.45;
    
    path.moveTo(0, midY);
    path.lineTo(size.width * 0.15, midY);
    path.lineTo(size.width * 0.20, midY - 15);
    path.lineTo(size.width * 0.25, midY + 15);
    path.lineTo(size.width * 0.30, midY);
    path.lineTo(size.width * 0.45, midY);
    path.lineTo(size.width * 0.50, midY - 60); // High Spike
    path.lineTo(size.width * 0.55, midY + 45); // Deep Dip
    path.lineTo(size.width * 0.60, midY - 10);
    path.lineTo(size.width * 0.65, midY);
    path.lineTo(size.width * 0.80, midY);
    path.lineTo(size.width * 0.85, midY - 15);
    path.lineTo(size.width * 0.90, midY + 15);
    path.lineTo(size.width * 0.95, midY);
    path.lineTo(size.width, midY);

    canvas.drawPath(path, pulsePaint);
  }

  void _drawPillPatterns(Canvas canvas, Size size, Paint paint, Color primary, Color secondary) {
    _drawOrbs(canvas, size, paint, primary, secondary);

    final pillColor = (isDark ? AppTheme.primaryGreenLight : AppTheme.primaryGreen).withAlpha(15);
    
    // Draw 3 transparent pill illustrations in background
    _drawPill(canvas, Offset(size.width * 0.2, size.height * 0.25), 45.0, 30.0, pillColor);
    _drawPill(canvas, Offset(size.width * 0.8, size.height * 0.6), -30.0, 40.0, pillColor);
    _drawPill(canvas, Offset(size.width * 0.3, size.height * 0.75), 15.0, 25.0, pillColor);
  }

  void _drawPill(Canvas canvas, Offset center, double angleDegrees, double scale, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleDegrees * pi / 180);

    final pillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw capsule halves
    final rect = Rect.fromCenter(center: Offset.zero, width: scale * 2.0, height: scale * 0.8);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(scale * 0.4));
    
    canvas.drawRRect(rrect, pillPaint);

    // Draw division line
    final linePaint = Paint()
      ..color = color.withAlpha(50)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -scale * 0.4), Offset(0, scale * 0.4), linePaint);

    canvas.restore();
  }

  void _drawAIStars(Canvas canvas, Size size, Paint paint, Color primary, Color secondary) {
    _drawOrbs(canvas, size, paint, primary, secondary);

    final starColor = AppTheme.accentBlue.withAlpha(isDark ? 50 : 35);
    
    // Draw sparkling/magic stars for AI theme
    _drawStar(canvas, Offset(size.width * 0.85, 80), 16, starColor);
    _drawStar(canvas, Offset(size.width * 0.75, 130), 8, starColor);
    _drawStar(canvas, Offset(size.width * 0.15, size.height * 0.35), 24, starColor);
    _drawStar(canvas, Offset(size.width * 0.25, size.height * 0.42), 10, starColor);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 4 point star
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);

    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.isDark != isDark;
  }
}
