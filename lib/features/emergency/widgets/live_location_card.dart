import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../emergency_sos_mock_data.dart';

/// Dummy live location card.
///
/// Displays a static map placeholder with coordinates and address.
/// Replace the painted map with google_maps_flutter GoogleMap widget
/// when ready for production integration. The model [SOSLocation]
/// already has lat/lng fields ready for CameraPosition.
class LiveLocationCard extends StatefulWidget {
  final SOSLocation location;
  final bool isTracking;

  const LiveLocationCard({
    super.key,
    required this.location,
    required this.isTracking,
  });

  @override
  State<LiveLocationCard> createState() => _LiveLocationCardState();
}

class _LiveLocationCardState extends State<LiveLocationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  late Animation<double> _dotAnim;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _dotAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _dotController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Map placeholder ──
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                // Map background (replace with GoogleMap widget)
                Container(
                  height: 160,
                  width: double.infinity,
                  color: isDark
                      ? const Color(0xFF1A2E1F)
                      : const Color(0xFFE8F5E9),
                  child: CustomPaint(
                    painter: _MapPlaceholderPainter(isDark: isDark),
                  ),
                ),

                // Google Maps integration hint overlay
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pin icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.statusRed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.statusRed.withAlpha(100),
                                blurRadius: 14,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.my_location_rounded,
                              color: Colors.white, size: 22),
                        ),
                        // Pin stem
                        Container(
                          width: 3,
                          height: 10,
                          color: AppTheme.statusRed,
                        ),
                        Container(
                          width: 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.statusRed.withAlpha(60),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Maps integration badge (top-right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_rounded,
                            color: Colors.white, size: 11),
                        SizedBox(width: 4),
                        Text(
                          'Maps Integration Ready',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Accuracy radius ring
                Positioned.fill(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _dotAnim,
                      builder: (_, __) => Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentBlue
                                .withAlpha((_dotAnim.value * 80).toInt()),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Location info row ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Live indicator
                    AnimatedBuilder(
                      animation: _dotAnim,
                      builder: (_, __) => Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isTracking
                              ? AppTheme.primaryGreen
                                  .withAlpha((_dotAnim.value * 255).toInt())
                              : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isTracking ? 'LIVE TRACKING' : 'LOCATION PAUSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: widget.isTracking
                            ? AppTheme.primaryGreen
                            : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '±${widget.location.accuracyMeters.toStringAsFixed(1)}m accuracy',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.location.address,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.location.city,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                // Coordinates chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.accentBlue.withAlpha(40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gps_fixed_rounded,
                          color: AppTheme.accentBlue, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        widget.location.coordinateString,
                        style: const TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Updated: ${widget.location.lastUpdated}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map grid painter ──────────────────────────────────────

class _MapPlaceholderPainter extends CustomPainter {
  final bool isDark;
  _MapPlaceholderPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withAlpha(12)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    const step = 30.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw road-like lines
    final roadPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withAlpha(20)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.70, 0), Offset(size.width * 0.70, size.height), roadPaint);

    // Draw building blocks
    final blockPaint = Paint()
      ..color = (isDark ? Colors.white : AppTheme.primaryGreen).withAlpha(15)
      ..style = PaintingStyle.fill;

    final blocks = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.1, 60, 40),
      Rect.fromLTWH(size.width * 0.42, size.height * 0.1, 80, 30),
      Rect.fromLTWH(size.width * 0.75, size.height * 0.1, 55, 45),
      Rect.fromLTWH(size.width * 0.05, size.height * 0.6, 70, 35),
      Rect.fromLTWH(size.width * 0.42, size.height * 0.6, 65, 40),
      Rect.fromLTWH(size.width * 0.75, size.height * 0.6, 50, 30),
    ];
    for (final rect in blocks) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)), blockPaint);
    }
  }

  @override
  bool shouldRepaint(_MapPlaceholderPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
