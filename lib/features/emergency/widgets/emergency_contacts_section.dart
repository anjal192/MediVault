import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../emergency_sos_mock_data.dart';

/// Emergency Contacts section for the SOS screen.
/// Shows primary contacts first with a call button.
/// Ready for url_launcher (tel: scheme) integration.
class EmergencyContactsSection extends StatelessWidget {
  final List<SOSContact> contacts;
  final bool sosIsActive;
  final void Function(SOSContact contact) onCallContact;

  const EmergencyContactsSection({
    super.key,
    required this.contacts,
    required this.sosIsActive,
    required this.onCallContact,
  });

  @override
  Widget build(BuildContext context) {
    // Sort: primary contacts first
    final sorted = [...contacts]
      ..sort((a, b) {
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;
        return 0;
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sorted
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ContactCard(
                  contact: c,
                  sosIsActive: sosIsActive,
                  onCall: () => onCallContact(c),
                ),
              ))
          .toList(),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final SOSContact contact;
  final bool sosIsActive;
  final VoidCallback onCall;

  const _ContactCard({
    required this.contact,
    required this.sosIsActive,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPrimary = contact.isPrimary;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isPrimary
          ? AppTheme.statusRed.withAlpha(isDark ? 20 : 10)
          : null,
      borderAlpha: isPrimary ? 50 : 20,
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: contact.avatarColor,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: contact.avatarColor.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                contact.avatarInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + relation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.statusRed.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRIMARY',
                          style: TextStyle(
                            color: AppTheme.statusRed,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${contact.relation} · ${contact.phone}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                // Notified badge when SOS is active
                if (sosIsActive) ...[
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppTheme.primaryGreen, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Notified with your location',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Call button
          GestureDetector(
            onTap: onCall,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sosIsActive
                    ? AppTheme.statusRed
                    : AppTheme.primaryGreen,
                boxShadow: [
                  BoxShadow(
                    color: (sosIsActive
                            ? AppTheme.statusRed
                            : AppTheme.primaryGreen)
                        .withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
