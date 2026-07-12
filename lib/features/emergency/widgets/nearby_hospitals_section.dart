import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../emergency_sos_mock_data.dart';

/// Nearby hospitals section with distance, ETA, specialty, and call button.
/// Sorted by distance. Ready for Google Places API / Directions API integration.
class NearbyHospitalsSection extends StatelessWidget {
  final List<NearbyHospital> hospitals;
  final void Function(NearbyHospital hospital) onGetDirections;
  final void Function(NearbyHospital hospital) onCallHospital;

  const NearbyHospitalsSection({
    super.key,
    required this.hospitals,
    required this.onGetDirections,
    required this.onCallHospital,
  });

  @override
  Widget build(BuildContext context) {
    // Sort by distance
    final sorted = [...hospitals]
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return Column(
      children: sorted
          .map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HospitalCard(
                  hospital: h,
                  onGetDirections: () => onGetDirections(h),
                  onCall: () => onCallHospital(h),
                ),
              ))
          .toList(),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final NearbyHospital hospital;
  final VoidCallback onGetDirections;
  final VoidCallback onCall;

  const _HospitalCard({
    required this.hospital,
    required this.onGetDirections,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon + name + distance ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hospital type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hospital.accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _hospitalIcon(hospital.type),
                  color: hospital.accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hospital.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Emergency unit badge
                        if (hospital.hasEmergencyUnit)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.statusRed.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppTheme.statusRed.withAlpha(50)),
                            ),
                            child: const Text(
                              'EMERGENCY',
                              style: TextStyle(
                                color: AppTheme.statusRed,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hospital.specialty,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Stats row: distance + ETA + rating ──
          Row(
            children: [
              _StatChip(
                icon: Icons.directions_car_rounded,
                label: '${hospital.distanceKm} km',
                color: AppTheme.accentBlue,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.timer_outlined,
                label: hospital.estimatedArrival,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.star_rounded,
                label: hospital.rating.toString(),
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Address ──
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  hospital.address,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Action buttons ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentBlue,
                    side: BorderSide(
                        color: AppTheme.accentBlue.withAlpha(80)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onGetDirections,
                  // TODO: Replace with Maps URL launcher:
                  // url_launcher -> google.com/maps/dir/?destination=lat,lng
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text('Directions',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hospital.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onCall,
                  // TODO: Replace with url_launcher tel: scheme
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: const Text('Call',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _hospitalIcon(HospitalType type) {
    switch (type) {
      case HospitalType.cardiac:
        return Icons.favorite_border_rounded;
      case HospitalType.trauma:
        return Icons.local_hospital_outlined;
      case HospitalType.children:
        return Icons.child_care_outlined;
      case HospitalType.general:
        return Icons.local_hospital_rounded;
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
