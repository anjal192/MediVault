import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';

class PersonalHealthRecordScreen extends StatelessWidget {
  const PersonalHealthRecordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = MediVaultRepository();
    final record = repo.healthRecord;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Health Record"),
      ),
      body: GradientBackground(
        style: BackgroundStyle.medicalCross,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // 1. Patient identity overview card
            _buildIdentityCard(repo.userName, record.bloodGroup, isDark),
            const SizedBox(height: 24),

            // 2. Allergies Card
            _buildSectionCard(
              title: "Allergies",
              icon: Icons.warning_amber_rounded,
              color: AppTheme.statusRed,
              items: record.allergies,
            ),
            const SizedBox(height: 16),

            // 3. Chronic Conditions
            _buildSectionCard(
              title: "Chronic Diseases",
              icon: Icons.favorite_border_rounded,
              color: AppTheme.statusYellow,
              items: record.chronicDiseases,
            ),
            const SizedBox(height: 16),

            // 4. Past Surgeries
            _buildSectionCard(
              title: "Surgeries & Operations",
              icon: Icons.local_hospital_outlined,
              color: AppTheme.accentBlue,
              items: record.pastSurgeries,
            ),
            const SizedBox(height: 16),

            // 5. Vaccinations
            _buildSectionCard(
              title: "Vaccination Log",
              icon: Icons.vaccines_outlined,
              color: AppTheme.primaryGreen,
              items: record.vaccinations,
            ),
            const SizedBox(height: 24),

            // 6. Emergency Contacts
            const Text(
              "Emergency Contacts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ...record.emergencyContacts.map((contact) => _buildContactCard(context, contact)),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(String name, String bloodGroup, bool isDark) {
    return GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primaryGreen.withAlpha(20),
            child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 2),
                const Text("Record ID: MV-897365-ND", style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.statusRed.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.statusRed.withAlpha(30)),
            ),
            child: Column(
              children: [
                const Icon(Icons.bloodtype, color: AppTheme.statusRed, size: 22),
                Text(
                  bloodGroup.split(' ').first, // extract O-
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.statusRed, fontSize: 13),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 24),
          if (items.isEmpty)
            const Text("No medical records registered.", style: TextStyle(fontSize: 13, color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withAlpha(40)),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, dynamic contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.statusRed.withAlpha(15),
              child: const Icon(Icons.emergency_share, color: AppTheme.statusRed, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    "${contact.relation} • ${contact.phone}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: AppTheme.primaryGreen),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Calling ${contact.name} (${contact.phone})..."),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
