import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/constants/mock_data.dart';
import 'package:intl/intl.dart';

class MedicineInventoryScreen extends StatefulWidget {
  const MedicineInventoryScreen({Key? key}) : super(key: key);

  @override
  State<MedicineInventoryScreen> createState() => _MedicineInventoryScreenState();
}

class _MedicineInventoryScreenState extends State<MedicineInventoryScreen> with SingleTickerProviderStateMixin {
  late final MediVaultRepository _repository;
  late final NotificationService _notificationService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _repository = MediVaultRepository();
    _notificationService = NotificationService();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Inventory"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryGreen,
          isScrollable: true,
          tabs: const [
            Tab(text: "All Meds"),
            Tab(text: "Running Low ⚠️"),
            Tab(text: "Expired ⏳"),
            Tab(text: "Completed ✅"),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _repository,
        builder: (context, _) {
          final meds = _repository.medicines;
          final lowStock = meds.where((m) => m.stockStatus != 'Green' && !m.isCompleted && !m.isExpired).toList();
          final expired = meds.where((m) => m.isExpired).toList();
          final completed = meds.where((m) => m.isCompleted).toList();
          final healthy = meds.where((m) => m.stockStatus == 'Green' && !m.isExpired).toList();

          return GradientBackground(
            style: BackgroundStyle.pillPattern,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryList(meds, isDark),
                _buildInventoryList(lowStock, isDark, emptyMsg: "No medications running low!"),
                _buildInventoryList(expired, isDark, emptyMsg: "No expired medications in your vault."),
                _buildInventoryList(completed, isDark, emptyMsg: "No completed medicine courses."),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryList(List<Medicine> list, bool isDark, {String emptyMsg = "No medicines recorded."}) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassCard(
            child: Text(emptyMsg, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final med = list[index];
        return _buildInventoryCard(med, isDark);
      },
    );
  }

  Widget _buildInventoryCard(Medicine med, bool isDark) {
    Color statusColor;
    String statusLabel = "";
    
    if (med.isExpired) {
      statusColor = AppTheme.statusRed;
      statusLabel = "Expired";
    } else if (med.isCompleted) {
      statusColor = Colors.grey;
      statusLabel = "Completed course";
    } else {
      switch (med.stockStatus) {
        case 'Red':
          statusColor = AppTheme.statusRed;
          statusLabel = "Critical Stock (${med.daysLeft} days left)";
          break;
        case 'Yellow':
          statusColor = AppTheme.statusYellow;
          statusLabel = "Low Stock (${med.daysLeft} days left)";
          break;
        default:
          statusColor = AppTheme.statusGreen;
          statusLabel = "In Stock (${med.daysLeft} days left)";
      }
    }

    // Ratio for progress bar
    double progressRatio = 0.0;
    if (med.totalQuantity > 0) {
      progressRatio = med.remainingQuantity / med.totalQuantity;
      if (progressRatio > 1.0) progressRatio = 1.0;
      if (progressRatio < 0.0) progressRatio = 0.0;
    }

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
                        med.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (med.isPrescribed && med.doctorName != null)
                        Text(
                          "Prescribed by: ${med.doctorName}",
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 8,
                      backgroundColor: statusColor.withAlpha(30),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${med.remainingQuantity}/${med.totalQuantity}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Expiry Date: ${DateFormat('yyyy-MM-dd').format(med.expiryDate)}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      "Daily Consumption: ${med.dailyUsage} pill(s)/day",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                
                // If Low Stock or Completed, suggest reorder!
                if (med.stockStatus != 'Green' || med.isCompleted)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      _showReorderConfirmDialog(context, med);
                    },
                    child: const Text("Reorder", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showReorderConfirmDialog(BuildContext context, Medicine med) {
    final reorderAmount = med.totalQuantity > 0 ? med.totalQuantity : 30;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
        title: Row(
          children: [
            const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryGreen, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text("Reorder: ${med.name}")),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Would you like to confirm the order of $reorderAmount tablets of ${med.name}?"),
            const SizedBox(height: 12),
            const Text(
              "Order details:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text("• Estimated delivery: 2-3 Days\n• Quantity: $reorderAmount Tablets\n• Status: Simulated Confirmation"),
            const SizedBox(height: 12),
            const Text(
              "Note: MediVault will never order automatically. Orders are confirmed only on explicit click.",
              style: TextStyle(color: Colors.grey, fontSize: 11),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              
              // Direct order confirmation
              _notificationService.handleReorderConfirm(med.id, reorderAmount);
            },
            child: const Text("Confirm Order"),
          )
        ],
      ),
    );
  }
}
