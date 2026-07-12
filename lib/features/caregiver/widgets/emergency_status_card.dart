import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../caregiver_mock_data.dart';

/// Emergency Status card displaying:
/// - Current emergency status indicator (green = Safe / red = SOS)
/// - Patient location
/// - "View Live Location" button (stub — ready for Maps integration)
/// - "Call Patient" button (stub — ready for URL launcher integration)
class EmergencyStatusCard extends StatelessWidget {
  final EmergencyStatus status;
  final String patientPhone;

  const EmergencyStatusCard({
    super.key,
    required this.status,
    required this.patientPhone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSOSActive = status.isSOS;
    final primaryColor =
        isSOSActive ? AppTheme.statusRed : AppTheme.primaryGreen;

    return GlassCard(
      padding: EdgeInsets.zero,
      color: primaryColor.withAlpha(isDark ? 20 : 12),
      borderAlpha: isSOSActive ? 80 : 30,
      child: Column(
        children: [
          // ── Header banner ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withAlpha(isDark ? 50 : 30),
                  primaryColor.withAlpha(0),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                // Animated status indicator
                _StatusPulse(isActive: isSOSActive, color: primaryColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Emergency Status',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status.statusLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // SOS badge
                if (isSOSActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.statusRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Location + last checked row ──
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Last Known Location',
                  value: status.patientLocation,
                  color: AppTheme.accentBlue,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Last Checked',
                  value: status.lastChecked,
                  color: primaryColor,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // ── Divider ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
                height: 1,
                color: primaryColor.withAlpha(40)),
          ),

          // ── Action buttons ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // View Live Location
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentBlue,
                      side: BorderSide(
                          color: AppTheme.accentBlue.withAlpha(80)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final query = Uri.encodeComponent(status.patientLocation);
                      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        if (context.mounted) {
                          _showStubSnackbar(context, 'Could not launch maps for ${status.patientLocation}');
                        }
                      }
                    },
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text(
                      'Live Location',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Call Patient
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse('tel:$patientPhone');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        if (context.mounted) {
                          _showStubSnackbar(context, 'Could not launch dialer for $patientPhone');
                        }
                      }
                    },
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: Text(
                      isSOSActive ? 'Call Now!' : 'Call Patient',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-builders ──────────────────────────────────────

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showStubSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Animated pulsing status dot ──────────────────────────

class _StatusPulse extends StatefulWidget {
  final bool isActive;
  final Color color;

  const _StatusPulse({required this.isActive, required this.color});

  @override
  State<_StatusPulse> createState() => _StatusPulseState();
}

class _StatusPulseState extends State<_StatusPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: false);

    _scaleAnim = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isActive)
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Transform.scale(
                  scale: _scaleAnim.value,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color
                          .withAlpha((_opacityAnim.value * 255).toInt()),
                    ),
                  ),
                );
              },
            ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withAlpha(80),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
