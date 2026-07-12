import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../caregiver_mock_data.dart';

/// Medicine history section:
/// - 7-day calendar timeline (dot indicators per day)
/// - Weekly adherence bar chart (fl_chart)
/// - Overall adherence percentage badge
class AdherenceCalendarSection extends StatelessWidget {
  final List<DailyAdherence> weeklyData;

  const AdherenceCalendarSection({super.key, required this.weeklyData});

  // Calculate overall weekly adherence
  double get _overallAdherence {
    if (weeklyData.isEmpty) return 0;
    final totalTaken =
        weeklyData.fold(0, (sum, d) => sum + d.takenMeds);
    final totalMeds =
        weeklyData.fold(0, (sum, d) => sum + d.totalMeds);
    return totalMeds == 0 ? 0 : (totalTaken / totalMeds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adherencePct = (_overallAdherence * 100).round();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medicine History',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Last 7 days',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              // Adherence badge
              _buildAdherenceBadge(adherencePct),
            ],
          ),

          const SizedBox(height: 20),

          // ── Calendar timeline (7 dots) ──
          _buildCalendarTimeline(isDark),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ── Bar chart header ──
          const Text(
            'Daily Adherence Graph',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // ── fl_chart bar chart ──
          SizedBox(
            height: 130,
            child: _buildBarChart(isDark),
          ),
        ],
      ),
    );
  }

  // ── Calendar Timeline ─────────────────────────────────

  Widget _buildCalendarTimeline(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weeklyData.map((day) {
        final isToday = _isToday(day.date);
        final dotColor = day.isPerfect
            ? AppTheme.primaryGreen
            : day.isMissed
                ? AppTheme.statusRed
                : AppTheme.statusYellow;

        return Column(
          children: [
            // Day label
            Text(
              DateFormat('EEE').format(day.date),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday
                    ? AppTheme.primaryGreen
                    : isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            // Date number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday
                    ? AppTheme.primaryGreen
                    : dotColor.withAlpha(25),
                border: Border.all(
                  color: isToday
                      ? AppTheme.primaryGreen
                      : dotColor.withAlpha(80),
                  width: 1.5,
                ),
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withAlpha(60),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${day.date.day}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : dotColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Taken/total label
            Text(
              '${day.takenMeds}/${day.totalMeds}',
              style: TextStyle(
                fontSize: 9,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ── Bar Chart ─────────────────────────────────────────

  Widget _buildBarChart(bool isDark) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: isDark
                ? AppTheme.surfaceDark
                : Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}%',
                const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= weeklyData.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('E').format(weeklyData[index].date),
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                );
              },
              reservedSize: 22,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) => FlLine(
            color: (isDark ? Colors.white : Colors.black).withAlpha(12),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(isDark),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(bool isDark) {
    return List.generate(weeklyData.length, (index) {
      final day = weeklyData[index];
      final pct = day.percentage * 100;
      final color = pct >= 80
          ? AppTheme.primaryGreen
          : pct >= 40
              ? AppTheme.statusYellow
              : AppTheme.statusRed;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: pct,
            color: color,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: (isDark ? Colors.white : Colors.black).withAlpha(10),
            ),
          ),
        ],
      );
    });
  }

  // ── Helpers ───────────────────────────────────────────

  Widget _buildAdherenceBadge(int pct) {
    final color = pct >= 80
        ? AppTheme.primaryGreen
        : pct >= 50
            ? AppTheme.statusYellow
            : AppTheme.statusRed;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            value: pct / 100,
            strokeWidth: 5,
            backgroundColor: color.withAlpha(30),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Text(
          '$pct%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
