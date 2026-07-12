import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../caregiver_mock_data.dart';

/// A horizontal-scroll list of medicine status cards for today's schedule.
/// Each card shows: icon, name, time, dosage, and a color-coded status chip.
class TodayMedicinesSection extends StatelessWidget {
  final List<CaregiverMedicine> medicines;

  const TodayMedicinesSection({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Medicines",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${medicines.length} scheduled',
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Adherence summary strip ──
        _buildAdherenceSummary(medicines),
        const SizedBox(height: 14),

        // ── Horizontal scrollable medicine cards ──
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: medicines.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return MedicineStatusCard(medicine: medicines[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceSummary(List<CaregiverMedicine> meds) {
    final taken = meds.where((m) => m.status == MedStatus.taken).length;
    final missed = meds.where((m) => m.status == MedStatus.missed).length;
    final pending = meds.where((m) => m.status == MedStatus.pending).length;

    return Row(
      children: [
        _summaryChip(
          Icons.check_circle_outline,
          '$taken Taken',
          AppTheme.primaryGreen,
        ),
        const SizedBox(width: 8),
        _summaryChip(
          Icons.schedule_outlined,
          '$pending Pending',
          const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 8),
        _summaryChip(
          Icons.cancel_outlined,
          '$missed Missed',
          AppTheme.statusRed,
        ),
      ],
    );
  }

  Widget _summaryChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual medicine status card — used inside [TodayMedicinesSection].
class MedicineStatusCard extends StatelessWidget {
  final CaregiverMedicine medicine;

  const MedicineStatusCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(medicine.status);
    final statusLabel = _statusLabel(medicine.status);
    final statusIcon = _statusIcon(medicine.status);

    return GlassCard(
      width: 148,
      padding: const EdgeInsets.all(14),
      // Subtle left-border accent using colored container wrapping
      child: Stack(
        children: [
          // Left accent bar
          Positioned(
            left: -14,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine icon circle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _medicineIcon(medicine.iconName),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 10),
                        const SizedBox(width: 3),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Medicine name
              Text(
                medicine.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: medicine.status == MedStatus.missed
                      ? AppTheme.statusRed
                      : null,
                  decoration: medicine.status == MedStatus.taken
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              // Dosage
              Text(
                medicine.dosage,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 2),
              // Time
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 11,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    medicine.time,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────

  Color _statusColor(MedStatus status) {
    switch (status) {
      case MedStatus.taken:
        return AppTheme.primaryGreen;
      case MedStatus.pending:
        return const Color(0xFFF59E0B);
      case MedStatus.missed:
        return AppTheme.statusRed;
    }
  }

  String _statusLabel(MedStatus status) {
    switch (status) {
      case MedStatus.taken:
        return 'Taken';
      case MedStatus.pending:
        return 'Pending';
      case MedStatus.missed:
        return 'Missed';
    }
  }

  IconData _statusIcon(MedStatus status) {
    switch (status) {
      case MedStatus.taken:
        return Icons.check_circle;
      case MedStatus.pending:
        return Icons.schedule;
      case MedStatus.missed:
        return Icons.cancel;
    }
  }

  IconData _medicineIcon(String iconName) {
    switch (iconName) {
      case 'capsule':
        return Icons.hourglass_empty_rounded;
      case 'tablet':
        return Icons.circle_outlined;
      case 'syrup':
        return Icons.medication_liquid;
      default:
        return Icons.medication_rounded;
    }
  }
}
