import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';

class EmergencyHealthCardScreen extends StatelessWidget {
  const EmergencyHealthCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MediVaultRepository();
    final record = repo.healthRecord;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Health Card"),
        backgroundColor: AppTheme.statusRed,
        foregroundColor: Colors.white,
      ),
      body: GradientBackground(
        style: BackgroundStyle.heartBeat,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // 1. High Visibility Flashing Emergency Header
            _buildEmergencyHeader(),
            const SizedBox(height: 20),

            // 2. Simulated QR Code card
            _buildQRCodeCard(isDark),
            const SizedBox(height: 20),

            // 3. Hot Dial Button
            _buildHotDialButton(context),
            const SizedBox(height: 24),

            // 4. Critical Medical Info
            const Text(
              "Critical Medical Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildMedicalDetailsCard(record),
            const SizedBox(height: 24),

            // 5. Quick Contacts
            const Text(
              "Emergency Contact Hotlines",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ...record.emergencyContacts.map((c) => _buildEmergencyContactCard(context, c)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.statusRed,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.statusRed.withAlpha(80),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.health_and_safety, color: Colors.white, size: 36),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FIRST RESPONDER ALERT",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Scan QR or read details below in case of crisis.",
                  style: TextStyle(color: Color(0xDEFFFFFF), fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQRCodeCard(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      borderAlpha: 50,
      child: Column(
        children: [
          const Text(
            "MediVault Emergency Access",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
          ),
          const SizedBox(height: 4),
          const Text(
            "Scan to access full records, allergies and medication history.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Custom Painted QR Code representation
          Center(
            child: Container(
              width: 160,
              height: 160,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withAlpha(20)),
              ),
              child: CustomPaint(
                painter: QRCodePainter(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "PATIENT ID: MV-897365-ND",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildHotDialButton(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.statusRed,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Simulating outgoing call to Emergency Services (911)..."),
              backgroundColor: AppTheme.statusRed,
            ),
          );
        },
        icon: const Icon(Icons.phone_in_talk, size: 24),
        label: const Text(
          "CALL PARAMEDICS (911)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMedicalDetailsCard(dynamic record) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemRow("Patient Name", "John Doe"),
          _buildItemRow("Blood Type", record.bloodGroup, isCritical: true),
          _buildItemRow("Severe Allergies", record.allergies.join(', '), isCritical: true),
          _buildItemRow("Active Conditions", record.chronicDiseases.join(', ')),
          _buildItemRow("Important Surgeries", record.pastSurgeries.join(', ')),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, String value, {bool isCritical = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCritical ? AppTheme.statusRed : AppTheme.primaryGreen),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
              color: isCritical ? AppTheme.statusRed : null,
            ),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(BuildContext context, dynamic contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        color: AppTheme.statusRed.withAlpha(10),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.statusRed,
              child: Icon(Icons.emergency, color: Colors.white, size: 20),
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
              icon: const Icon(Icons.phone_forwarded, color: AppTheme.statusRed),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Calling Emergency Contact: ${contact.name} (${contact.phone})..."),
                    backgroundColor: AppTheme.statusRed,
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

// Custom Painter to draw a QR code pattern block
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final double squareSize = size.width / 15.0; // 15x15 grids

    // Helper to draw filled boxes
    void drawBox(int col, int row, int width, int height) {
      canvas.drawRect(
        Rect.fromLTWH(col * squareSize, row * squareSize, width * squareSize, height * squareSize),
        paint,
      );
    }

    // Top-Left Anchor
    drawBox(0, 0, 4, 4);
    paint.color = Colors.white;
    drawBox(1, 1, 2, 2);
    paint.color = Colors.black;
    drawBox(1, 1, 1, 1);

    // Top-Right Anchor
    drawBox(11, 0, 4, 4);
    paint.color = Colors.white;
    drawBox(12, 1, 2, 2);
    paint.color = Colors.black;
    drawBox(12, 1, 1, 1);

    // Bottom-Left Anchor
    drawBox(0, 11, 4, 4);
    paint.color = Colors.white;
    drawBox(1, 12, 2, 2);
    paint.color = Colors.black;
    drawBox(1, 12, 1, 1);

    // Random noise patterns (simulated QR squares)
    drawBox(6, 0, 2, 1);
    drawBox(5, 2, 1, 2);
    drawBox(8, 2, 2, 1);
    drawBox(6, 5, 3, 2);
    drawBox(1, 6, 2, 1);
    drawBox(10, 6, 1, 3);
    drawBox(13, 8, 2, 2);
    drawBox(5, 9, 2, 1);
    drawBox(8, 9, 1, 3);
    drawBox(2, 10, 2, 1);
    drawBox(10, 11, 2, 2);
    drawBox(6, 12, 3, 1);
    drawBox(13, 13, 1, 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
