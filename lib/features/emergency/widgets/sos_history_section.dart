import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../emergency_sos_mock_data.dart';

/// SOS History section — shows past SOS events with outcome, duration,
/// location, notified contacts, and notes. Expandable per event.
class SOSHistorySection extends StatefulWidget {
  final List<SOSHistoryEvent> history;

  const SOSHistorySection({super.key, required this.history});

  @override
  State<SOSHistorySection> createState() => _SOSHistorySectionState();
}

class _SOSHistorySectionState extends State<SOSHistorySection> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return const GlassCard(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline,
                  color: AppTheme.primaryGreen, size: 36),
              SizedBox(height: 10),
              Text(
                'No SOS events recorded',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                'Your emergency history will appear here.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Newest first
    final sorted = [...widget.history]
      ..sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));

    return Column(
      children: sorted
          .map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SOSEventCard(
                  event: event,
                  isExpanded: _expanded.contains(event.id),
                  onToggle: () => setState(() {
                    if (_expanded.contains(event.id)) {
                      _expanded.remove(event.id);
                    } else {
                      _expanded.add(event.id);
                    }
                  }),
                ),
              ))
          .toList(),
    );
  }
}

class _SOSEventCard extends StatelessWidget {
  final SOSHistoryEvent event;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SOSEventCard({
    required this.event,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outcomeColor = _outcomeColor(event.outcome);
    final outcomeLabel = _outcomeLabel(event.outcome);
    final outcomeIcon = _outcomeIcon(event.outcome);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Column(
          children: [
            // ── Header (always visible) ──
            InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Outcome icon circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: outcomeColor.withAlpha(25),
                      ),
                      child: Icon(outcomeIcon,
                          color: outcomeColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: outcomeColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  outcomeLabel,
                                  style: TextStyle(
                                    color: outcomeColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (event.duration != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '• ${_formatDuration(event.duration!)}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, yyyy · hh:mm a')
                                .format(event.triggeredAt),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // ── Expanded detail panel ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedPanel(isDark, outcomeColor),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPanel(bool isDark, Color outcomeColor) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withAlpha(6),
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),

          // Location
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: event.location,
            color: AppTheme.accentBlue,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // Contacts notified
          _buildDetailRow(
            icon: Icons.people_alt_outlined,
            label: 'Contacts Notified',
            value: event.contactsNotified.join(', '),
            color: AppTheme.primaryGreen,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // Notes
          _buildDetailRow(
            icon: Icons.notes_rounded,
            label: 'Notes',
            value: event.notes,
            color: Colors.grey,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────

  Color _outcomeColor(SOSHistoryOutcome outcome) {
    switch (outcome) {
      case SOSHistoryOutcome.resolved:
        return AppTheme.primaryGreen;
      case SOSHistoryOutcome.falseAlarm:
        return AppTheme.statusYellow;
      case SOSHistoryOutcome.cancelled:
        return Colors.grey;
      case SOSHistoryOutcome.hospitalized:
        return AppTheme.statusRed;
    }
  }

  String _outcomeLabel(SOSHistoryOutcome outcome) {
    switch (outcome) {
      case SOSHistoryOutcome.resolved:
        return 'RESOLVED';
      case SOSHistoryOutcome.falseAlarm:
        return 'FALSE ALARM';
      case SOSHistoryOutcome.cancelled:
        return 'CANCELLED';
      case SOSHistoryOutcome.hospitalized:
        return 'HOSPITALIZED';
    }
  }

  IconData _outcomeIcon(SOSHistoryOutcome outcome) {
    switch (outcome) {
      case SOSHistoryOutcome.resolved:
        return Icons.check_circle_outline;
      case SOSHistoryOutcome.falseAlarm:
        return Icons.warning_amber_rounded;
      case SOSHistoryOutcome.cancelled:
        return Icons.cancel_outlined;
      case SOSHistoryOutcome.hospitalized:
        return Icons.local_hospital_outlined;
    }
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes}m duration';
    return '${d.inHours}h ${d.inMinutes % 60}m duration';
  }
}
