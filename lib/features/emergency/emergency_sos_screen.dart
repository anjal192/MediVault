import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import 'emergency_sos_mock_data.dart';
import 'widgets/sos_button.dart';
import 'widgets/emergency_contacts_section.dart';
import 'widgets/live_location_card.dart';
import 'widgets/nearby_hospitals_section.dart';
import 'widgets/sos_history_section.dart';
import 'widgets/emergency_instructions_section.dart';

/// Emergency SOS Screen
///
/// State machine: idle → activating → active → (cancelled | resolved)
///
/// Future integrations ready:
///  - geolocator: replace [MockSOSDatabase.liveLocation] with GPS stream
///  - google_maps_flutter: replace LiveLocationCard painter with GoogleMap
///  - url_launcher: replace call stubs with tel: and maps: URLs
///  - Firebase: persist SOS events to [MockSOSDatabase.sosHistory]
///  - FCM: send push notifications to contacts on SOS trigger
///
/// Route: '/emergency-sos'
class EmergencySOSScreen extends StatefulWidget {
  const EmergencySOSScreen({super.key});

  @override
  State<EmergencySOSScreen> createState() => _EmergencySOSScreenState();
}

class _EmergencySOSScreenState extends State<EmergencySOSScreen>
    with TickerProviderStateMixin {
  // ── SOS State ──────────────────────────────────────────
  SOSStatus _status = SOSStatus.idle;
  static const int _countdownSeconds = 5;
  int _remainingSeconds = _countdownSeconds;
  Timer? _countdownTimer;

  // ── Local data (replace with repository calls) ──────────
  final _contacts = MockSOSDatabase.contacts;
  final _location = MockSOSDatabase.liveLocation;
  final _hospitals = MockSOSDatabase.nearbyHospitals;
  final List<SOSHistoryEvent> _history = MockSOSDatabase.sosHistory;
  final _aiSummary = MockSOSDatabase.instructions;

  // ── Animation ──────────────────────────────────────────
  late AnimationController _screenShakeController;
  late AnimationController _bgController;
  late Animation<Color?> _bgColorAnim;

  // ── Scroll tracking ────────────────────────────────────
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _screenShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bgColorAnim = ColorTween(
      begin: Colors.transparent,
      end: AppTheme.statusRed.withAlpha(20),
    ).animate(CurvedAnimation(
        parent: _bgController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _screenShakeController.dispose();
    _bgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── SOS State Machine ───────────────────────────────────

  void _onSOSPressed() {
    if (_status != SOSStatus.idle) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _status = SOSStatus.activating;
      _remainingSeconds = _countdownSeconds;
    });

    _bgController.forward();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });

      HapticFeedback.lightImpact();

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _activateSOS();
      }
    });
  }

  void _activateSOS() {
    HapticFeedback.heavyImpact();
    setState(() {
      _status = SOSStatus.active;
    });

    // Future: trigger FCM push, Firestore write, SMS API here
    _showSOSActivatedBanner();
  }

  void _cancelSOS() {
    _countdownTimer?.cancel();
    HapticFeedback.mediumImpact();

    final wasActive = _status == SOSStatus.active;

    setState(() {
      _status = SOSStatus.idle;
      _remainingSeconds = _countdownSeconds;
    });

    _bgController.reverse();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasActive
              ? '✅ Marked as safe. Contacts will be notified.'
              : '❌ SOS Cancelled.',
        ),
        backgroundColor: wasActive
            ? AppTheme.primaryGreen
            : Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSOSActivatedBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.emergency_share_rounded,
                color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'SOS Alert Sent! Contacts and emergency services notified.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.statusRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onCallContact(SOSContact contact) async {
    final uri = Uri.parse('tel:${contact.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch dialer for ${contact.phone}'),
            backgroundColor: AppTheme.statusRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _onGetDirections(NearbyHospital hospital) async {
    final query = Uri.encodeComponent(hospital.name);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch maps for ${hospital.name}'),
            backgroundColor: AppTheme.statusRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _onCallHospital(NearbyHospital hospital) async {
    final uri = Uri.parse('tel:${hospital.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch dialer for ${hospital.phone}'),
            backgroundColor: AppTheme.statusRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── Build ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActivating = _status == SOSStatus.activating;
    final isActive = _status == SOSStatus.active;

    return Scaffold(
      // Transparent app bar so the SOS hero area bleeds full-width
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isActive || isActivating ? Colors.white : null,
          ),
          onPressed: () {
            if (_status != SOSStatus.idle) {
              _cancelSOS();
            }
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Emergency SOS',
          style: TextStyle(
            color: isActive || isActivating ? Colors.white : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Quick call 911 button always visible
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.statusRed.withAlpha(
                    isActive || isActivating ? 60 : 20),
                foregroundColor: AppTheme.statusRed,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _onCallContact(_contacts.last),
              icon: const Icon(Icons.phone_in_talk_rounded, size: 15),
              label: const Text(
                '911',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _bgColorAnim,
        builder: (context, child) {
          return Stack(
            children: [
              // Page-level background
              const GradientBackground(
                style: BackgroundStyle.heartBeat,
                child: SizedBox.expand(),
              ),

              // SOS active red overlay
              Positioned.fill(
                child: ColoredBox(
                  color: _bgColorAnim.value ?? Colors.transparent,
                ),
              ),

              // Scrollable content
              child!,
            ],
          );
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── SOS Hero Section ───────────────────────────────
            SliverToBoxAdapter(
              child: _buildSOSHero(isDark, isActive, isActivating),
            ),

            // ── Body sections ──────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Emergency Contacts
                  _SectionHeader(
                    icon: Icons.people_alt_outlined,
                    label: 'Emergency Contacts',
                    iconColor: AppTheme.statusRed,
                    trailing: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/health-record');
                      },
                      child: const Text('Manage',
                          style:
                              TextStyle(color: AppTheme.primaryGreen)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  EmergencyContactsSection(
                    contacts: _contacts,
                    sosIsActive: isActive,
                    onCallContact: _onCallContact,
                  ),

                  const SizedBox(height: 28),

                  // 2. Live Location
                  const _SectionHeader(
                    icon: Icons.gps_fixed_rounded,
                    label: 'Live Location',
                    iconColor: AppTheme.accentBlue,
                  ),
                  const SizedBox(height: 10),
                  LiveLocationCard(
                    location: _location,
                    isTracking: isActive || isActivating,
                  ),

                  const SizedBox(height: 28),

                  // 3. Nearby Hospitals
                  const _SectionHeader(
                    icon: Icons.local_hospital_outlined,
                    label: 'Nearby Hospitals',
                    iconColor: Color(0xFFE91E63),
                  ),
                  const SizedBox(height: 10),
                  NearbyHospitalsSection(
                    hospitals: _hospitals,
                    onGetDirections: _onGetDirections,
                    onCallHospital: _onCallHospital,
                  ),

                  const SizedBox(height: 28),

                  // 4. Emergency Instructions
                  const _SectionHeader(
                    icon: Icons.menu_book_outlined,
                    label: 'Emergency Instructions',
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  EmergencyInstructionsSection(
                    instructions: _aiSummary,
                  ),

                  const SizedBox(height: 28),

                  // 5. SOS History
                  _SectionHeader(
                    icon: Icons.history_rounded,
                    label: 'SOS History',
                    iconColor: Colors.purple,
                    trailing: _history.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_history.length} events',
                              style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  SOSHistorySection(history: _history),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SOS Hero ─────────────────────────────────────────────

  Widget _buildSOSHero(bool isDark, bool isActive, bool isActivating) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 70,
        bottom: 36,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  const Color(0xFFB71C1C).withAlpha(isDark ? 200 : 180),
                  const Color(0xFF7F0000).withAlpha(isDark ? 160 : 120),
                ]
              : isActivating
                  ? [
                      AppTheme.statusRed.withAlpha(isDark ? 120 : 80),
                      Colors.transparent,
                    ]
                  : [
                      AppTheme.primaryGreen.withAlpha(isDark ? 40 : 25),
                      Colors.transparent,
                    ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Status label on top of button
          if (isActive)
            _buildActiveStatusBanner(),

          if (isActive) const SizedBox(height: 20),

          // Central SOS button
          SOSButton(
            isActive: isActive,
            isActivating: isActivating,
            countdownSeconds: _countdownSeconds,
            remainingSeconds: _remainingSeconds,
            onPressed: _onSOSPressed,
            onCancel: _cancelSOS,
          ),

          if (!isActive && !isActivating) ...[
            const SizedBox(height: 24),
            _buildIdleQuickActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emergency_share_rounded,
              color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text(
            'SOS ACTIVE — Broadcasting Location',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuickActionButton(
          icon: Icons.phone_in_talk_rounded,
          label: 'Call 911',
          color: AppTheme.statusRed,
          onTap: () => _onCallContact(_contacts.last),
        ),
        const SizedBox(width: 16),
        _QuickActionButton(
          icon: Icons.local_hospital_outlined,
          label: 'Nearest ER',
          color: const Color(0xFFE91E63),
          onTap: () => _onGetDirections(_hospitals.first),
        ),
        const SizedBox(width: 16),
        _QuickActionButton(
          icon: Icons.people_alt_outlined,
          label: 'Call Contact',
          color: Colors.purple,
          onTap: () => _onCallContact(_contacts.first),
        ),
      ],
    );
  }
}

// ── Reusable Section Header ────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Quick Action Button ────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(60), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
