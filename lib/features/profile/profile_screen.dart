import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = MediVaultRepository();
  bool _notificationsEnabled = true;
  bool _isLoggingOut = false;

  // Edit profile dialog state
  final _nameEditController = TextEditingController();
  final _ageEditController = TextEditingController();
  final _weightEditController = TextEditingController();
  final _heightEditController = TextEditingController();
  final _allergiesEditController = TextEditingController();

  @override
  void dispose() {
    _nameEditController.dispose();
    _ageEditController.dispose();
    _weightEditController.dispose();
    _heightEditController.dispose();
    _allergiesEditController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out from MediVault?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Log Out", style: TextStyle(color: AppTheme.statusRed)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);
    try {
      await FirebaseAuthService().signOut();
    } catch (_) {
      // Proceed even if Firebase signout fails (offline)
    }
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _openEditProfileDialog() {
    // Pre-fill controllers
    _nameEditController.text = _repo.userName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildEditSheet(ctx),
    );
  }

  Widget _buildEditSheet(BuildContext ctx) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameEditController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageEditController,
                    decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weightEditController,
                    decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _heightEditController,
                    decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _allergiesEditController,
              decoration: const InputDecoration(
                labelText: "Allergies (comma-separated)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning_amber_outlined),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  // Update Firestore user profile
                  final uid = FirebaseAuthService().currentUser?.uid;
                  if (uid != null) {
                    final updates = <String, dynamic>{
                      'name': _nameEditController.text.trim(),
                    };
                    if (_ageEditController.text.isNotEmpty) {
                      updates['age'] = int.tryParse(_ageEditController.text.trim()) ?? 0;
                    }
                    if (_weightEditController.text.isNotEmpty) {
                      updates['weight'] = double.tryParse(_weightEditController.text.trim()) ?? 0.0;
                    }
                    if (_heightEditController.text.isNotEmpty) {
                      updates['height'] = double.tryParse(_heightEditController.text.trim()) ?? 0.0;
                    }
                    if (_allergiesEditController.text.isNotEmpty) {
                      updates['allergies'] = _allergiesEditController.text.trim().split(',').map((e) => e.trim()).toList();
                    }

                    try {
                      await FirestoreService().updateUserProfile(uid, updates);
                    } catch (e) {
                      debugPrint("Profile update error: $e");
                    }
                  }

                  if (mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile updated!"),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  }
                },
                child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _openEditProfileDialog,
            tooltip: "Edit Profile",
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: _repo,
        builder: (context, _) {
          final todayMeds = _repo.todayMedicines;
          final adherence = _repo.adherenceProgress;
          final totalMeds = _repo.medicines.length;

          return GradientBackground(
            style: BackgroundStyle.glowingOrbs,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // 1. Profile Card
                _buildProfileCard(_repo.userName, _repo.userEmail, _repo.profileCompletion, isDark),
                const SizedBox(height: 20),

                // 2. Stats Box
                _buildStatsCard(todayMeds.length, totalMeds, adherence),
                const SizedBox(height: 24),

                // 3. Settings
                _buildSettingsHeader("Health Dashboard"),
                _buildSettingsTile(context, Icons.history_edu, "Personal Health Record", "Allergies, conditions, surgeries", "/health-record"),
                _buildSettingsTile(context, Icons.calendar_month, "Doctor Appointments", "Schedule and clinic visits", "/dashboard"),
                _buildSettingsTile(context, Icons.folder_shared, "Prescription Archive", "Simplified uploads and logs", "/vault"),

                const SizedBox(height: 16),
                _buildSettingsHeader("App Preferences"),
                _buildSettingsTile(context, Icons.volume_up, "Voice Reminder (TTS) Settings", "Speech volume, pitch, speed", "/reminders"),
                _buildSettingsTile(context, Icons.translate, "App Language", "English (US)", null, trailingText: "English"),
                _buildNotificationTile(),

                const SizedBox(height: 16),
                _buildSettingsHeader("Support & Privacy"),
                _buildSettingsTile(context, Icons.security, "Privacy & Terms", "Data encryption rules", null),
                _buildSettingsTile(context, Icons.help_outline, "Help Center", "FAQs and user support manuals", null),

                const SizedBox(height: 24),

                // Logout button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.statusRed,
                    side: const BorderSide(color: AppTheme.statusRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoggingOut ? null : _logout,
                  icon: _isLoggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.statusRed),
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: const Text("Log Out from Device", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(String name, String email, int completion, bool isDark) {
    return GlassCard(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: completion / 100.0,
                  strokeWidth: 4,
                  backgroundColor: AppTheme.primaryGreen.withAlpha(30),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
              ),
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primaryGreen.withAlpha(20),
                child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 36),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Profile Complete: $completion%",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsCard(int activeMeds, int totalMeds, double adherence) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Active Meds", "$activeMeds / $totalMeds"),
          _buildDivider(),
          _buildStatItem("Today Adherence", "${(adherence * 100).toInt()}%"),
          _buildDivider(),
          _buildStatItem("Health Score", "92/100"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.withAlpha(50));
  }

  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 8.0, top: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildNotificationTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Notification Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text("Low stock & daily reminder alerts", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Switch(
              value: _notificationsEnabled,
              activeColor: AppTheme.primaryGreen,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    String? route, {
    String? trailingText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            if (trailingText != null)
              Text(trailingText, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold))
            else if (route != null)
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
