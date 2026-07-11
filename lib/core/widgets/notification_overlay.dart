import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/repository.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';
import '../constants/mock_data.dart';
import 'package:intl/intl.dart';

class NotificationOverlay extends StatefulWidget {
  final Widget child;

  const NotificationOverlay({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<NotificationOverlay> {
  late final NotificationService _notificationService;
  late final MediVaultRepository _repository;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _repository = MediVaultRepository();
    
    // Listen to changes to trigger rebuilds
    _notificationService.addListener(_onNotificationChanged);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationChanged);
    super.dispose();
  }

  void _onNotificationChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final active = _notificationService.activeOverlayNotification;

    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        if (active != null)
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: active.type == NotificationType.doctorAppointment
                      ? AppTheme.accentBlue.withAlpha(20)
                      : active.type == NotificationType.lowStock
                          ? AppTheme.statusRed.withAlpha(20)
                          : AppTheme.primaryGreen.withAlpha(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            active.type == NotificationType.doctorAppointment
                                ? Icons.medical_services_rounded
                                : active.type == NotificationType.lowStock
                                    ? Icons.warning_amber_rounded
                                    : Icons.alarm_rounded,
                            color: active.type == NotificationType.doctorAppointment
                                ? AppTheme.accentBlue
                                : active.type == NotificationType.lowStock
                                    ? AppTheme.statusRed
                                    : AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              active.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _notificationService.dismissActiveOverlay(),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        active.body,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _buildActions(context, active),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context, AppNotification notif) {
    final style = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    if (notif.type == NotificationType.medicineReminder) {
      final medId = notif.metadata['medId'];
      return [
        TextButton(
          style: style,
          onPressed: () {
            if (medId != null) _repository.skipMedicine(medId);
            _notificationService.dismissActiveOverlay();
          },
          child: const Text("Skip", style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            if (medId != null) _repository.takeMedicine(medId);
            _notificationService.dismissActiveOverlay();
          },
          child: const Text("Take"),
        ),
      ];
    } else if (notif.type == NotificationType.lowStock) {
      final medId = notif.metadata['medId'];
      final reorderQty = notif.metadata['reorderQty'] ?? 30;
      return [
        TextButton(
          style: style,
          onPressed: () => _notificationService.dismissActiveOverlay(),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            if (medId != null) {
              _notificationService.handleReorderConfirm(medId, reorderQty);
            }
          },
          child: const Text("Confirm Order"),
        ),
      ];
    } else if (notif.type == NotificationType.doctorAppointment) {
      return [
        TextButton(
          style: style,
          onPressed: () => _notificationService.dismissActiveOverlay(),
          child: const Text("Dismiss", style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            _notificationService.dismissActiveOverlay();
            _showDoctorVisitSurvey(context, notif.metadata['doctorName'] ?? "Doctor");
          },
          child: const Text("Log Visit Details"),
        ),
      ];
    }
    return [];
  }

  void _showDoctorVisitSurvey(BuildContext context, String doctorName) {
    final formKey = GlobalKey<FormState>();
    String medName = "";
    int tabletsPurchased = 30;
    int durationDays = 30;
    int dailyUsage = 1;
    DateTime nextApptDate = DateTime.now().add(const Duration(days: 90));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final overlayBg = isDark ? AppTheme.surfaceDark : Colors.white;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: overlayBg,
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
                      Text(
                        "Visit Log: $doctorName",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Update your medication inventory and next appointment details based on your visit.",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const Divider(height: 24),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Medication Name',
                          hintText: 'e.g. Lipitor, Metformin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medication),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? "Please enter medicine name" : null,
                        onSaved: (v) => medName = v ?? "",
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Tablets Purchased',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue: "30",
                              validator: (v) => int.tryParse(v ?? "") == null ? "Required" : null,
                              onSaved: (v) => tabletsPurchased = int.parse(v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Duration (Days)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue: "30",
                              validator: (v) => int.tryParse(v ?? "") == null ? "Required" : null,
                              onSaved: (v) => durationDays = int.parse(v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Daily Usage (Pills/Day)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: "1",
                        validator: (v) => int.tryParse(v ?? "") == null ? "Required" : null,
                        onSaved: (v) => dailyUsage = int.parse(v!),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: nextApptDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (selected != null) {
                            setModalState(() {
                              nextApptDate = selected;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Next Appointment Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          child: Text(DateFormat('yyyy-MM-dd').format(nextApptDate)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              
                              // Update repository
                              _repository.updateInventoryPostDoctorVisit(
                                medName,
                                durationDays,
                                tabletsPurchased,
                                dailyUsage,
                              );

                              // Register next appointment
                              _repository.scheduleAppointment(
                                DoctorAppointment(
                                  id: 'appt_new_${DateTime.now().millisecondsSinceEpoch}',
                                  doctorName: doctorName,
                                  specialty: "Follow-up Visit",
                                  dateTime: nextApptDate,
                                  location: "Doctor's Clinic",
                                ),
                              );

                              Navigator.pop(context);

                              // Show success banner
                              _notificationService.triggerNotification(
                                "Inventory Updated ✅",
                                "Added $tabletsPurchased tablets of $medName. Next visit scheduled.",
                                NotificationType.medicineReminder,
                              );
                            }
                          },
                          child: const Text("Save and Update", style: TextStyle(fontWeight: FontWeight.bold)),
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
