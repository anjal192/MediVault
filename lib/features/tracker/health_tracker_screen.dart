import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../core/constants/mock_data.dart';
import 'package:intl/intl.dart';

class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  final _repository = MediVaultRepository();
  String _selectedMetricType = "BP_SYS"; // default selection (Systolic Blood Pressure)

  final Map<String, String> _metricTitles = {
    "BP_SYS": "Blood Pressure (Systolic)",
    "BP_DIA": "Blood Pressure (Diastolic)",
    "SUGAR": "Blood Sugar (mg/dL)",
    "WEIGHT": "Body Weight (kg)",
    "HEART_RATE": "Heart Rate (bpm)",
    "SPO2": "Oxygen Level SpO₂ (%)",
    "TEMP": "Temperature (°C)",
  };

  final Map<String, Color> _metricColors = {
    "BP_SYS": Colors.red,
    "BP_DIA": Colors.pink,
    "SUGAR": Colors.orange,
    "WEIGHT": Colors.blue,
    "HEART_RATE": Colors.redAccent,
    "SPO2": Colors.teal,
    "TEMP": Colors.amber,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Tracker"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMetricSheet(context),
        icon: const Icon(Icons.add),
        label: const Text("Log Vitals"),
        backgroundColor: _metricColors[_selectedMetricType] ?? AppTheme.primaryGreen,
      ),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          // Filter logs by current selected type
          final filteredLogs = _repository.trackerLogs
              .where((log) => log.type == _selectedMetricType)
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          final historyList = filteredLogs.reversed.toList(); // newest first for history list

          return GradientBackground(
            style: BackgroundStyle.heartBeat,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // 1. Metric selector scrollable horizontal list
                _buildMetricSelectorChips(),
                const SizedBox(height: 20),

                // 2. High-end Line Chart
                _buildChartCard(filteredLogs, isDark),
                const SizedBox(height: 24),

                // 3. History Log list header
                Text(
                  "Historical Logs: ${_metricTitles[_selectedMetricType]}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // 4. Log Cards
                if (historyList.isEmpty)
                  const GlassCard(
                    child: Center(child: Text("No records logged for this metric yet.")),
                  )
                else
                  ...historyList.map((log) => _buildHistoryItemCard(log)),
                  
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricSelectorChips() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _metricTitles.entries.map((entry) {
          final isSelected = _selectedMetricType == entry.key;
          final color = _metricColors[entry.key] ?? AppTheme.primaryGreen;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(entry.value.split(' ').first), // e.g. "Blood" or "Oxygen"
              selected: isSelected,
              selectedColor: color.withAlpha(35),
              labelStyle: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedMetricType = entry.key;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartCard(List<HealthMetric> logs, bool isDark) {
    final themeColor = _metricColors[_selectedMetricType] ?? AppTheme.primaryGreen;
    
    return GlassCard(
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 24),
      height: 250,
      child: logs.length < 2
          ? Center(
              child: Text(
                "Need at least 2 logs to show a graph trend.\nCurrently logged: ${logs.length}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          : LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1.0,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < logs.length) {
                          // Show day index or date abbreviation
                          return Text(
                            DateFormat('MM/dd').format(logs[idx].timestamp),
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                          );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(logs.length, (i) {
                      return FlSpot(i.toDouble(), logs[i].value);
                    }),
                    isCurved: true,
                    color: themeColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 5,
                        color: themeColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: themeColor.withAlpha(20),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHistoryItemCard(HealthMetric log) {
    final color = _metricColors[log.type] ?? AppTheme.primaryGreen;
    final dateStr = DateFormat('yyyy-MM-dd • hh:mm a').format(log.timestamp);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withAlpha(15), shape: BoxShape.circle),
              child: Icon(Icons.monitor_heart, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${log.value.toStringAsFixed(1)} ${_getUnit(log.type)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  if (log.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Note: ${log.notes}",
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUnit(String type) {
    if (type == "BP_SYS" || type == "BP_DIA") return "mmHg";
    if (type == "SUGAR") return "mg/dL";
    if (type == "WEIGHT") return "kg";
    if (type == "HEART_RATE") return "bpm";
    if (type == "SPO2") return "%";
    if (type == "TEMP") return "°C";
    return "";
  }

  void _showAddMetricSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    double loggedVal = 0.0;
    String loggedNotes = "";
    String sheetType = _selectedMetricType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bg = isDark ? AppTheme.surfaceDark : Colors.white;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(80),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Log Medical Vital Reading",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const Divider(height: 24),
                      DropdownButtonFormField<String>(
                        initialValue: sheetType,
                        decoration: const InputDecoration(
                          labelText: 'Select Vital Metric',
                          border: OutlineInputBorder(),
                        ),
                        items: _metricTitles.entries.map((e) {
                          return DropdownMenuItem(value: e.key, child: Text(e.value));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              sheetType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Measurement Value',
                          suffixText: _getUnit(sheetType),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => double.tryParse(v ?? "") == null ? "Please enter a valid numeric value" : null,
                        onSaved: (v) => loggedVal = double.parse(v!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Notes / Context',
                          hintText: 'e.g. resting, fasting, after walking',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (v) => loggedNotes = v ?? "",
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _metricColors[sheetType] ?? AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              
                              // Save to database
                              _repository.addTrackerMetric(sheetType, loggedVal, loggedNotes);
                              
                              // Set local selection to match what was added so user sees it instantly
                              setState(() {
                                _selectedMetricType = sheetType;
                              });

                              Navigator.pop(ctx);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Successfully logged reading of $loggedVal ${_getUnit(sheetType)}"),
                                  backgroundColor: AppTheme.primaryGreen,
                                ),
                              );
                            }
                          },
                          child: const Text("Save Vital Record", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
