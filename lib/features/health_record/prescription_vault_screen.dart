import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';

class PrescriptionVaultScreen extends StatelessWidget {
  const PrescriptionVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MediVaultRepository();
    final prescriptions = repo.prescriptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription Vault"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/ai-simplifier'),
        icon: const Icon(Icons.document_scanner),
        label: const Text("Scan New Prescription"),
      ),
      body: GradientBackground(
        style: BackgroundStyle.aiStars,
        child: prescriptions.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: GlassCard(
                    child: Text(
                      "No digital prescriptions archived. Tap 'Scan' to simplify and save one.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: prescriptions.length,
                itemBuilder: (context, index) {
                  final item = prescriptions[index];
                  return _buildPrescriptionCard(context, item);
                },
              ),
      ),
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.doctorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Visit Date: ${item.dateString}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (item.isAIAnalyzed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primaryGreen.withAlpha(45)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppTheme.primaryGreen, size: 10),
                        SizedBox(width: 4),
                        Text(
                          "AI Simplified",
                          style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 9),
                        ),
                      ],
                    ),
                  )
              ],
            ),
            
            const Divider(height: 20),
            
            // Diagnosis
            const Text(
              "DIAGNOSIS / CONDITION",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 2),
            Text(
              item.diagnosis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 12),
            
            // Simplified meds summary
            const Text(
              "EXTRACTED MEDICINES",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 4),
            ...item.simplifiedMedicines.map<Widget>((med) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, size: 16, color: AppTheme.primaryGreen),
                    Expanded(
                      child: Text(
                        med,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 12),

            // Notes
            const Text(
              "DOCTOR INSTRUCTIONS",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 2),
            Text(
              item.notes,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
