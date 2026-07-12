import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.blur = 15.0,
    this.borderAlpha = 30, // 0-255 opacity
    this.backgroundAlpha = 15, // 0-255 opacity
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose custom colors based on dark/light modes
    final baseColor = color ?? (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight);
    final shadowColor = isDark ? Colors.black.withAlpha(50) : AppTheme.primaryGreen.withAlpha(12);

    Widget cardBody = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: baseColor.withAlpha(isDark ? 160 : 210), // Glass transparency
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: (isDark ? Colors.white : AppTheme.primaryGreen).withAlpha(borderAlpha.toInt()),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: child,
    );

    // Apply tap interaction if provided
    if (onTap != null) {
      cardBody = InkWell(
        onTap: onTap,
        borderRadius: AppTheme.cardRadius,
        child: cardBody,
      );
    }

    // Apply backdrop blur if it's set
    if (blur > 0) {
      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: AppTheme.cardRadius,
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
