import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/constants/mock_data.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final MediVaultRepository _repository;
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _repository = MediVaultRepository();
    _notificationService = NotificationService();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([_repository, _notificationService]),
        builder: (context, _) {
          final todayMeds = _repository.todayMedicines;
          final lowStockMeds = _repository.lowStockMedicines;
          final upcomingAppts = _repository.appointments;
          final adherence = _repository.adherenceProgress;
          final score = _repository.healthScore;

          return GradientBackground(
            style: BackgroundStyle.medicalCross,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: _buildHeader(score),
                  ),
                ),
              ],
              body: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  // 1. Low Stock alert banner
                  if (lowStockMeds.isNotEmpty) ...[
                    _buildLowStockBanner(lowStockMeds.first),
                    const SizedBox(height: 16),
                  ],

                  // 2. Adherence Tracker Summary Card
                  _buildAdherenceCard(adherence, todayMeds),
                  const SizedBox(height: 20),

                  // 3. Today's Medicine List
                  _buildTodayMedicinesList(todayMeds),
                  const SizedBox(height: 20),

                  // 4. Upcoming Doctor Appointment
                  _buildAppointmentCard(upcomingAppts),
                  const SizedBox(height: 20),

                  // 5. Quick Actions Grid
                  const Text(
                    "Quick Services",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionsGrid(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(double score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hello John,",
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const Text(
              "MediVault Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Health Score indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryGreen.withAlpha(50)),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: AppTheme.primaryGreen, size: 16),
              const SizedBox(width: 6),
              Text(
                "Score: ${score.toInt()}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 13),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildLowStockBanner(Medicine med) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      color: AppTheme.statusRed.withAlpha(15),
      borderAlpha: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: AppTheme.statusRed, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Low Stock Alert: ${med.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.statusRed, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Only ${med.remainingQuantity} tablet(s) remaining. Purchase suggested.",
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _notificationService.simulateLowStockAlert(med);
                },
                child: const Text("Order Now", style: TextStyle(color: AppTheme.statusRed, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAdherenceCard(double progress, List<Medicine> meds) {
    final taken = meds.where((m) => m.isTaken).length;
    final total = meds.length;
    final percent = (progress * 100).toInt();

    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Medication Adherence",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  "$taken of $total medications taken today",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    percent == 100 ? "Perfect Score! 🌟" : "Keep going!",
                    style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.primaryGreen.withAlpha(30),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
              ),
              Text(
                "$percent%",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTodayMedicinesList(List<Medicine> meds) {
    if (meds.isEmpty) {
      return GlassCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No medications scheduled for today."),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Medicines",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/reminders'),
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () {
                    // Quick Action: toggle taken state
                    if (!med.isTaken) {
                      _repository.takeMedicine(med.id);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            med.iconName == 'capsule'
                                ? Icons.hourglass_empty
                                : med.iconName == 'tablet'
                                    ? Icons.circle_outlined
                                    : Icons.medication_liquid,
                            color: med.isTaken ? Colors.grey : AppTheme.primaryGreen,
                            size: 22,
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: med.isTaken
                                  ? AppTheme.primaryGreen
                                  : med.isSkipped
                                      ? AppTheme.statusRed
                                      : Colors.grey.withAlpha(80),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        med.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          decoration: med.isTaken ? TextDecoration.lineThrough : null,
                          color: med.isTaken ? Colors.grey : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${med.dosage} • ${med.time}",
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(List<DoctorAppointment> appts) {
    if (appts.isEmpty) return const SizedBox.shrink();
    final next = appts.first;
    final dateStr = DateFormat('EEE, MMM dd - hh:mm a').format(next.dateTime);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: AppTheme.accentBlue, size: 20),
              SizedBox(width: 8),
              Text(
                "Upcoming Appointment",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            next.doctorName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            next.specialty,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  // Simulate finishing a doctor visit to test inventory updates questionnaire
                  _notificationService.simulateDoctorVisitReminder(next);
                },
                child: const Text("Simulate Visit Finish", style: TextStyle(fontSize: 11)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final list = [
      _ActionItem(Icons.add_circle_outline_rounded, "Add Medicine", "/add-medicine", AppTheme.primaryGreen),
      _ActionItem(Icons.inventory_2_outlined, "Inventory", "/inventory", Colors.orange),
      _ActionItem(Icons.document_scanner_outlined, "AI Simplifier", "/ai-simplifier", AppTheme.accentBlue),
      _ActionItem(Icons.chat_bubble_outline_rounded, "AI Assistant", "/ai-chat", AppTheme.primaryGreen),
      _ActionItem(Icons.history_edu_rounded, "Health Record", "/health-record", Colors.purple),
      _ActionItem(Icons.folder_shared_outlined, "Vault Files", "/vault", Colors.teal),
      _ActionItem(Icons.monitor_heart_outlined, "Tracker Vitals", "/tracker", Colors.pink),
      _ActionItem(Icons.contact_emergency, "Emergency Card", "/emergency-card", AppTheme.statusRed, isGlowing: true),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: item.isGlowing ? AppTheme.statusRed.withAlpha(20) : null,
          borderAlpha: item.isGlowing ? 120 : 30,
          onTap: () {
            if (item.route == "/emergency-card") {
              // Custom navigation or open emergency screen
              Navigator.pushNamed(context, item.route);
            } else {
              Navigator.pushNamed(context, item.route);
            }
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: item.isGlowing ? AppTheme.statusRed : null,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  final bool isGlowing;

  _ActionItem(this.icon, this.label, this.route, this.color, {this.isGlowing = false});
}
