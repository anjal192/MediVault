import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../caregiver_mock_data.dart';

/// Notification Center section displaying all caregiver alert types:
/// Medicine Taken, Medicine Missed, Low Stock, Appointment Reminder,
/// Voice Reminder, and SOS Alert — each with color-coded styling.
class NotificationCenterSection extends StatefulWidget {
  final List<CaregiverNotification> notifications;

  const NotificationCenterSection({
    super.key,
    required this.notifications,
  });

  @override
  State<NotificationCenterSection> createState() =>
      _NotificationCenterSectionState();
}

class _NotificationCenterSectionState
    extends State<NotificationCenterSection> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final visibleNotifs = _showAll
        ? widget.notifications
        : widget.notifications.take(3).toList();

    final unreadCount =
        widget.notifications.where((n) => !n.isRead).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Notification Center',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.statusRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            TextButton(
              onPressed: () => setState(() => _showAll = !_showAll),
              child: Text(
                _showAll ? 'Show Less' : 'View All',
                style: const TextStyle(color: AppTheme.primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Notification cards ──
        ...visibleNotifs.map(
          (notif) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _NotifCard(notification: notif),
          ),
        ),
      ],
    );
  }
}

/// Individual notification card with left-border color accent.
class _NotifCard extends StatelessWidget {
  final CaregiverNotification notification;

  const _NotifCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _notifConfig(notification.type);
    final timeAgo = _formatTimeAgo(notification.timestamp);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 5,
              color: config.color,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon circle
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: config.color.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(config.icon,
                          color: config.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: config.color,
                                  ),
                                ),
                              ),
                              // Unread dot
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    color: config.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.body,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NotifConfig _notifConfig(CaregiverNotifType type) {
    switch (type) {
      case CaregiverNotifType.medicineTaken:
        return _NotifConfig(
            color: AppTheme.primaryGreen, icon: Icons.check_circle_outline);
      case CaregiverNotifType.medicineMissed:
        return _NotifConfig(
            color: AppTheme.statusRed, icon: Icons.cancel_outlined);
      case CaregiverNotifType.lowStock:
        return _NotifConfig(
            color: AppTheme.statusYellow,
            icon: Icons.warning_amber_rounded);
      case CaregiverNotifType.appointmentReminder:
        return _NotifConfig(
            color: AppTheme.accentBlue,
            icon: Icons.calendar_month_outlined);
      case CaregiverNotifType.voiceReminder:
        return _NotifConfig(
            color: Colors.purple, icon: Icons.volume_up_outlined);
      case CaregiverNotifType.sosAlert:
        return _NotifConfig(
            color: AppTheme.statusRed,
            icon: Icons.emergency_outlined);
    }
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d, hh:mm a').format(time);
  }
}

class _NotifConfig {
  final Color color;
  final IconData icon;
  _NotifConfig({required this.color, required this.icon});
}
