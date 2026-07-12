import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/notification_overlay.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/dashboard/main_hub.dart';
import 'features/medicine/medicine_reminder_screen.dart';
import 'features/medicine/add_medicine_screen.dart';
import 'features/medicine/medicine_inventory_screen.dart';
import 'features/ai/ai_prescription_simplifier_screen.dart';
import 'features/ai/ai_health_assistant_screen.dart';
import 'features/health_record/personal_health_record_screen.dart';
import 'features/health_record/prescription_vault_screen.dart';
import 'features/health_record/emergency_health_card_screen.dart';
import 'features/tracker/health_tracker_screen.dart';
import 'features/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase not configured yet — app runs in local-only mode
    debugPrint("Firebase init skipped: $e");
  }
  runApp(const MediVaultApp());
}


class MediVaultApp extends StatelessWidget {
  const MediVaultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediVault',
      debugShowCheckedModeBanner: false,
      
      // Theme settings (Material 3 premium palette)
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: ThemeMode.system, // respects device preferences
      
      // Initial Entry Page
      initialRoute: '/login', // temp: skip splash for direct testing
      
      // App Routing Map
      routes: {
        '/': (context) => const NotificationOverlay(child: SplashScreen()),
        '/login': (context) => const NotificationOverlay(child: LoginScreen()),
        '/register': (context) => const NotificationOverlay(child: RegisterScreen()),
        
        // Main Navigation Hub
        '/dashboard': (context) => const NotificationOverlay(child: MainHubScreen()),
        
        // Medicine Details & Modifiers
        '/reminders': (context) => const NotificationOverlay(child: MedicineReminderScreen()),
        '/add-medicine': (context) => const NotificationOverlay(child: AddMedicineScreen()),
        '/inventory': (context) => const NotificationOverlay(child: MedicineInventoryScreen()),
        
        // AI Services
        '/ai-simplifier': (context) => const NotificationOverlay(child: AIPrescriptionSimplifierScreen()),
        '/ai-chat': (context) => const NotificationOverlay(child: AIHealthAssistantScreen()),
        
        // Health Records & Vitals Trackers
        '/health-record': (context) => const NotificationOverlay(child: PersonalHealthRecordScreen()),
        '/vault': (context) => const NotificationOverlay(child: PrescriptionVaultScreen()),
        '/emergency-card': (context) => const NotificationOverlay(child: EmergencyHealthCardScreen()),
        '/tracker': (context) => const NotificationOverlay(child: HealthTrackerScreen()),
        '/profile': (context) => const NotificationOverlay(child: ProfileScreen()),
      },
    );
  }
}
