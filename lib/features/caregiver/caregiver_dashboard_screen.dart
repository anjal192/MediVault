import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import 'caregiver_mock_data.dart';
import 'widgets/patient_profile_card.dart';
import 'widgets/medicine_status_card.dart';
import 'widgets/adherence_calendar.dart';
import 'widgets/ai_summary_card.dart';
import 'widgets/notification_center_card.dart';
import 'widgets/emergency_status_card.dart';

/// Caregiver Dashboard Screen
///
/// Monitors a single patient. All data is static dummy data
/// sourced from [MockCaregiverDatabase]. The screen is structured
/// for future Firebase / BLoC / Provider integration:
///  - Replace `MockCaregiverDatabase` accessors with repository calls.
///  - Wrap state changes in a ChangeNotifier / Riverpod provider.
///
/// Navigation: '/caregiver-dashboard'
class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen>
    with TickerProviderStateMixin {
  // Local copies — replace with repository stream for real integration
  final _patient = MockCaregiverDatabase.patient;
  final _todayMeds = MockCaregiverDatabase.todayMedicines;
  final _weeklyAdherence = MockCaregiverDatabase.weeklyAdherence;
  final _aiSummary = MockCaregiverDatabase.aiSummary;
  final _notifications = MockCaregiverDatabase.notifications;
  final _emergency = MockCaregiverDatabase.emergencyStatus;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      body: GradientBackground(
        style: BackgroundStyle.heartBeat,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Collapsible App Bar ──────────────────────────────
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: isDark
                    ? AppTheme.backgroundDark.withAlpha(220)
                    : AppTheme.backgroundLight.withAlpha(220),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.only(left: 20, bottom: 16),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Caregiver Dashboard',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Monitoring: ${_patient.name}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen.withAlpha(30),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                actions: [
                  // Notification bell with unread badge
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          // Scroll to notification section (future deep link)
                        },
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppTheme.statusRed,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Emergency quick toggle
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.statusRed.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.statusRed.withAlpha(60)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.emergency_share_outlined,
                            color: AppTheme.statusRed, size: 20),
                        onPressed: () {
                          _showEmergencyDialog(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // ── Scrollable Body ──────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. ── Patient Profile ──────────────────────────
                    const _SectionLabel(
                      icon: Icons.person_outline_rounded,
                      label: 'Patient Profile',
                      iconColor: AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 10),
                    PatientProfileCard(patient: _patient),

                    const SizedBox(height: 28),

                    // 2. ── Today's Medicines ─────────────────────────
                    const _SectionLabel(
                      icon: Icons.medication_outlined,
                      label: "Today's Medicines",
                      iconColor: AppTheme.accentBlue,
                    ),
                    const SizedBox(height: 10),
                    TodayMedicinesSection(medicines: _todayMeds),

                    const SizedBox(height: 28),

                    // 3. ── Medicine History ──────────────────────────
                    const _SectionLabel(
                      icon: Icons.bar_chart_rounded,
                      label: 'Medicine History',
                      iconColor: Colors.purple,
                    ),
                    const SizedBox(height: 10),
                    AdherenceCalendarSection(weeklyData: _weeklyAdherence),

                    const SizedBox(height: 28),

                    // 4. ── AI Health Summary ─────────────────────────
                    const _SectionLabel(
                      icon: Icons.auto_awesome_rounded,
                      label: 'AI Health Summary',
                      iconColor: AppTheme.accentBlue,
                    ),
                    const SizedBox(height: 10),
                    AISummaryCard(summary: _aiSummary),

                    const SizedBox(height: 28),

                    // 5. ── Notification Center ───────────────────────
                    const _SectionLabel(
                      icon: Icons.notifications_outlined,
                      label: 'Notification Center',
                      iconColor: Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    NotificationCenterSection(
                        notifications: _notifications),

                    const SizedBox(height: 28),

                    // 6. ── Emergency Status ──────────────────────────
                    const _SectionLabel(
                      icon: Icons.emergency_share_outlined,
                      label: 'Emergency Status',
                      iconColor: AppTheme.statusRed,
                    ),
                    const SizedBox(height: 10),
                    EmergencyStatusCard(
                      status: _emergency,
                      patientPhone:
                          _patient.emergencyContactPhone,
                    ),

                    // Bottom padding
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Emergency Dialog ─────────────────────────────────

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emergency_share_outlined,
                color: AppTheme.statusRed),
            SizedBox(width: 8),
            Text('Emergency Alert',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send an SOS alert for ${_patient.name}?',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'This will notify ${_patient.emergencyContactName} (${_patient.emergencyContactRelation}) '
              'at ${_patient.emergencyContactPhone}.',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS Alert sent! Emergency contacts notified.'),
                  backgroundColor: AppTheme.statusRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send SOS',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Section Label ─────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
