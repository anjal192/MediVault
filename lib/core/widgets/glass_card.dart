import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final double blur;
  final double borderAlpha;
  final double backgroundAlpha;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.blur = 24.0,
    this.borderAlpha = 30,
    this.backgroundAlpha = 15,
    this.onTap,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);

    // ── Premium glassmorphism container ──────────────────────────────────────
    Widget cardBody = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        // Layered gradient background: blue-white glass effect
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A3A5C).withOpacity(0.55),   // Top-left: warm blue-glass
            const Color(0xFF0D1E36).withOpacity(0.75),   // Bottom-right: deep marine
          ],
        ),
        borderRadius: radius,
        // Shimmer border: top & left bright, bottom & right dimmer
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 1.4,
        ),
        boxShadow: [
          // Deep black base shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 16),
          ),
          // Outer electric-blue ambient glow
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.18),
            blurRadius: 60,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
          // Inner top highlight (bright glass edge)
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Top shimmer highlight line (premium glass depth cue) ─────────
          Positioned(
            top: 0,
            left: 20,
            right: 20,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );

    // Tap ripple
    if (onTap != null) {
      cardBody = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: cardBody,
      );
    }

    // Backdrop blur
    if (blur > 0) {
      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: cardBody,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: cardBody,
    );
  }
}
