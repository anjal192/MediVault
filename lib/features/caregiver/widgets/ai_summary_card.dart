import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../caregiver_mock_data.dart';

/// AI Health Summary card with:
/// - Health score ring (CircularProgressIndicator)
/// - Medicine adherence percentage
/// - Most frequently missed medicine chip
/// - AI recommendation text
///
/// All data is dummy — structured for future AI/ML API integration.
class AISummaryCard extends StatelessWidget {
  final AIHealthSummary summary;

  const AISummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor = _scoreColor(summary.healthScore);

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardRadius,
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0A1F2E),
                  const Color(0xFF0D2B1E),
                ]
              : [
                  const Color(0xFFEBF7FF),
                  const Color(0xFFECFBF2),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppTheme.getCardShadow(
            isDark ? Brightness.dark : Brightness.light),
        border: Border.all(
          color: AppTheme.accentBlue.withAlpha(isDark ? 40 : 30),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.accentBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Health Summary',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Powered by MediVault AI',
                      style:
                          TextStyle(fontSize: 11, color: AppTheme.accentBlue),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Score ring + stats row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Health Score Ring
                _buildScoreRing(summary.healthScore, scoreColor),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow(
                        icon: Icons.favorite_outline,
                        label: 'Health Score',
                        value: '${summary.healthScore}/100',
                        color: scoreColor,
                      ),
                      const SizedBox(height: 10),
                      _buildStatRow(
                        icon: Icons.medication_outlined,
                        label: 'Medicine Adherence',
                        value:
                            '${(summary.medicineAdherence * 100).round()}%',
                        color: summary.medicineAdherence >= 0.8
                            ? AppTheme.primaryGreen
                            : summary.medicineAdherence >= 0.5
                                ? AppTheme.statusYellow
                                : AppTheme.statusRed,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Most missed medicine chip ──
            _buildMissedMedicineChip(summary.mostFrequentlyMissedMedicine),

            const SizedBox(height: 14),

            // ── AI Recommendation ──
            _buildRecommendationBox(summary.recommendation, isDark),

            const SizedBox(height: 12),

            // ── Generated at ──
            Row(
              children: [
                const Icon(Icons.update_rounded,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Generated: ${summary.generatedAt}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-builders ──────────────────────────────────────

  Widget _buildScoreRing(int score, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            backgroundColor: color.withAlpha(30),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: color,
              ),
            ),
            Text(
              'Score',
              style: TextStyle(
                fontSize: 9,
                color: color.withAlpha(180),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissedMedicineChip(String medicine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.report_gmailerrorred_rounded,
            color: AppTheme.statusRed, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Most Frequently Missed',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.statusRed.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.statusRed.withAlpha(50)),
                ),
                child: Text(
                  medicine,
                  style: const TextStyle(
                    color: AppTheme.statusRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationBox(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withAlpha(isDark ? 20 : 12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: AppTheme.accentBlue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppTheme.primaryGreen;
    if (score >= 50) return AppTheme.statusYellow;
    return AppTheme.statusRed;
  }
}
