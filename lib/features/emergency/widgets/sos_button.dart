import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Large animated SOS button with:
/// - Multi-ring pulse animation (idle state)
/// - Circular countdown arc (activating state)
/// - Solid red glow (active state)
/// - Ripple cancel (cancelled state)
///
/// Callbacks are ready for backend SOS dispatch integration.
class SOSButton extends StatefulWidget {
  final bool isActive;
  final bool isActivating;
  final int countdownSeconds; // total seconds for countdown
  final int remainingSeconds; // seconds left before SOS fires
  final VoidCallback onPressed;
  final VoidCallback onCancel;

  const SOSButton({
    super.key,
    required this.isActive,
    required this.isActivating,
    required this.countdownSeconds,
    required this.remainingSeconds,
    required this.onPressed,
    required this.onCancel,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with TickerProviderStateMixin {
  // Idle pulse rings
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // Active glow throb
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.55).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Button + rings ──
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse rings (idle only)
              if (!widget.isActive && !widget.isActivating) ...[
                _buildPulseRing(1.0),
                _buildPulseRingDelayed(0.5),
              ],

              // Active glow rings
              if (widget.isActive)
                AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, __) => Container(
                    width: 195,
                    height: 195,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.statusRed
                              .withAlpha((_glowAnim.value * 120).toInt()),
                          blurRadius: 40 * _glowAnim.value,
                          spreadRadius: 10 * _glowAnim.value,
                        ),
                      ],
                    ),
                  ),
                ),

              // Countdown arc ring (activating)
              if (widget.isActivating)
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CustomPaint(
                    painter: _CountdownArcPainter(
                      progress: widget.remainingSeconds /
                          widget.countdownSeconds,
                      color: AppTheme.statusRed,
                    ),
                  ),
                ),

              // Core button
              GestureDetector(
                onTap: widget.isActive
                    ? null
                    : widget.isActivating
                        ? widget.onCancel
                        : widget.onPressed,
                child: AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, __) {
                    return Container(
                      width: 155,
                      height: 155,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: widget.isActive
                              ? [
                                  const Color(0xFFFF1744),
                                  const Color(0xFFB71C1C),
                                ]
                              : widget.isActivating
                                  ? [
                                      const Color(0xFFFF5252),
                                      const Color(0xFFD32F2F),
                                    ]
                                  : [
                                      const Color(0xFFFF3D3D),
                                      const Color(0xFFB71C1C),
                                    ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.statusRed.withAlpha(
                                widget.isActive
                                    ? (_glowAnim.value * 140).toInt()
                                    : 100),
                            blurRadius: widget.isActive ? 30 : 18,
                            spreadRadius: widget.isActive ? 6 : 2,
                          ),
                        ],
                      ),
                      child: _buildButtonContent(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Status label ──
        _buildStatusLabel(),

        // ── Cancel button (activating/active) ──
        if (widget.isActivating || widget.isActive) ...[
          const SizedBox(height: 16),
          _buildCancelButton(),
        ],
      ],
    );
  }

  // ── Pulse rings ────────────────────────────────────

  Widget _buildPulseRing(double animationOffset) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        return Transform.scale(
          scale: _pulseScale.value,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.statusRed
                    .withAlpha((_pulseOpacity.value * 255).toInt()),
                width: 2.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseRingDelayed(double delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final t = (_pulseController.value + delay) % 1.0;
        final scale = 1.0 + t * 0.55;
        final opacity = (1.0 - t) * 0.4;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.statusRed.withAlpha((opacity * 255).toInt()),
                width: 2.0,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Button inner content ──────────────────────────

  Widget _buildButtonContent() {
    if (widget.isActivating) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.remainingSeconds}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.bold,
              letterSpacing: -2,
            ),
          ),
          const Text(
            'HOLD',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ],
      );
    }

    if (widget.isActive) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emergency_share_rounded, color: Colors.white, size: 36),
          SizedBox(height: 4),
          Text(
            'SOS\nACTIVE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              height: 1.2,
            ),
          ),
        ],
      );
    }

    // Idle state
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'SOS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'HOLD TO SEND',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLabel() {
    final (label, color) = widget.isActive
        ? ('SOS Alert Sent — Help is on the way', AppTheme.statusRed)
        : widget.isActivating
            ? ('Sending in ${widget.remainingSeconds}s — tap to cancel', const Color(0xFFF59E0B))
            : ('Press and hold to trigger emergency alert', Colors.grey);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        label,
        key: ValueKey(widget.isActive ? 'active' : widget.isActivating ? 'activating' : 'idle'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: widget.onCancel,
      icon: const Icon(Icons.close_rounded, size: 18),
      label: Text(
        widget.isActive ? 'Mark as Safe' : 'Cancel SOS',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

// ── Countdown Arc Painter ─────────────────────────────────

class _CountdownArcPainter extends CustomPainter {
  final double progress; // 1.0 → 0.0 as countdown runs
  final Color color;

  _CountdownArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background track
    final trackPaint = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 4, trackPaint);

    // Progress arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_CountdownArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
