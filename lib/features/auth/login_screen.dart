import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: "john.doe@medivault.com");
  final _passController = TextEditingController(text: "password123");
  bool _obscureText = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _accentBlue = Color(0xFF60A5FA);
  static const Color _darkText = Color(0xFFF0F7FF);
  static const Color _grayText = Color(0xFFB0C4DE);
  static const Color _inputBorderFocus = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 800)); // simulate
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ─────────────────────────────────────────────
          Image.asset(
            'assets/images/stethoscope_light_bg.png',
            fit: BoxFit.cover,
          ),

          // ── Rich gradient overlay ────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE0050F1E), // Very dark top
                  Color(0xCC091A30), // Dark marine mid
                  Color(0x990A1E38), // Slightly lighter bottom
                ],
              ),
            ),
          ),

          // ── Subtle ambient orbs ──────────────────────────────────────────
          Positioned(
            top: -80,
            left: -60,
            child: _buildOrb(200, const Color(0xFF1565C0), 0.18),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: _buildOrb(220, const Color(0xFF0D47A1), 0.14),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBrandHeader(),
                        const SizedBox(height: 32),
                        _buildLoginCard(),
                        const SizedBox(height: 24),
                        _buildTrustBadges(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ambient orb helper ────────────────────────────────────────────────────
  Widget _buildOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }

  // ── Brand header ──────────────────────────────────────────────────────────
  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Icon with glass ring
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryBlue.withOpacity(0.40),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // App name — large, bold, friendly
        Text(
          'MediVault',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: _darkText,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),

        // Tagline — softer, readable
        Text(
          'Your medicines. Your health. Always protected.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _grayText,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Login card ────────────────────────────────────────────────────────────
  Widget _buildLoginCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      child: GlassCard(
        blur: 28,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading
              Text(
                'Welcome Back 👋',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to access your health records',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: _grayText,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // ── Divider ─────────────────────────────────────────────────
              _buildSectionDivider(),
              const SizedBox(height: 20),

              // Email
              _buildLabel('Email Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'john.doe@medivault.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Please enter a valid email'
                    : null,
              ),
              const SizedBox(height: 18),

              // Password
              _buildLabel('Password'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passController,
                hint: '••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _grayText,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureText = !_obscureText),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'At least 6 characters required'
                    : null,
              ),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: _accentBlue,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _accentBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login button
              _buildLoginButton(),
              const SizedBox(height: 24),

              // Register row
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: _grayText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      style: TextButton.styleFrom(
                        foregroundColor: _accentBlue,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Create Account →',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.12),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Login to your account',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _grayText.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: _darkText,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: GoogleFonts.inter(
        fontSize: 14.5,
        color: _darkText,
        fontWeight: FontWeight.w400,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF607D99),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(prefixIcon, color: _accentBlue, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF071525).withOpacity(0.70),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.10),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.10),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _inputBorderFocus, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFEF5350), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFEF5350), width: 1.8),
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFFEF9A9A),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [const Color(0xFF1A3A5C), const Color(0xFF1A3A5C)]
                : [const Color(0xFF1976D2), const Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: _primaryBlue.withOpacity(0.40),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildTrustBadges() {
    final badges = [
      (Icons.lock_outline_rounded, 'End-to-end Encrypted'),
      (Icons.verified_user_outlined, 'HIPAA Inspired'),
      (Icons.folder_special_outlined, 'Private Records'),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 10,
      children: badges.map((b) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(b.$1, size: 14, color: _grayText.withOpacity(0.75)),
            const SizedBox(width: 5),
            Text(
              b.$2,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: _grayText.withOpacity(0.75),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
