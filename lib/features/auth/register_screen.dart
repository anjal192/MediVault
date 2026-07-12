import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../core/services/repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  
  // Supplementary fields
  final _ageController = TextEditingController(text: "25");
  final _heightController = TextEditingController(text: "175");
  final _weightController = TextEditingController(text: "70");
  final _diseaseController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _doctorController = TextEditingController();

  String _selectedBloodGroup = 'O+';
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  
  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female', 'Other'];
  bool _undergoingTreatment = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _diseaseController.dispose();
    _allergiesController.dispose();
    _doctorController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else {
      // Complete Registration
      if (_formKey.currentState!.validate()) {
        setState(() => _isLoading = true);
        try {
          // 1. Sign up with Firebase
          final cred = await FirebaseAuthService().signUp(
            _emailController.text.trim(),
            _passController.text.trim(),
          );
          final uid = cred?.user?.uid ?? "john_doe_uid";

          // 2. Compute parameters
          final double h = double.tryParse(_heightController.text) ?? 170.0;
          final double w = double.tryParse(_weightController.text) ?? 70.0;
          final int age = int.tryParse(_ageController.text) ?? 25;

          final allergiesList = _allergiesController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

          final user = UserModel(
            uid: uid,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            age: age,
            gender: _selectedGender,
            bloodGroup: _selectedBloodGroup,
            height: h,
            weight: w,
            undergoingTreatment: _undergoingTreatment,
            diagnosedDisease: _undergoingTreatment ? _diseaseController.text.trim() : "",
            currentTreatment: _undergoingTreatment ? "Active Treatment Plan" : "",
            consultingDoctor: _undergoingTreatment ? _doctorController.text.trim() : "",
            foodAllergies: allergiesList,
            emergencyContacts: [
              EmergencyContactModel(
                name: _contactNameController.text.trim(),
                relation: "Emergency Contact",
                phone: _contactPhoneController.text.trim(),
              )
            ],
            profileCompletion: 100,
            healthScore: 92.0,
          );

          // 3. Save to Firestore
          await FirestoreService().saveUserProfile(user);

          // 4. Force repository baseline sync
          await MediVaultRepository().syncFromFirebase();

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Registration Failed: ${e.toString()}"),
                backgroundColor: AppTheme.statusRed,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep = 0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: GradientBackground(
        style: BackgroundStyle.glowingOrbs,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Indicators
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _currentStep == 1 ? AppTheme.primaryGreen : Colors.grey.withAlpha(80),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _currentStep == 0 ? "Step 1: Security Setup" : "Step 2: Medical Baseline",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: GlassCard(
                  child: _currentStep == 0 ? _buildStepOne() : _buildStepTwo(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _nextStep,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _currentStep == 0 ? "Continue" : "Complete Registration",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Personal Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.isEmpty) ? "Please enter your name" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (v) => (v == null || !v.contains('@')) ? "Please enter a valid email" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.length < 6) ? "Must be at least 6 characters" : null,
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Personal Health Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        
        // Age and Gender
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || int.tryParse(v) == null) ? "Invalid" : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGender = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Height and Weight
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || double.tryParse(v) == null) ? "Invalid" : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || double.tryParse(v) == null) ? "Invalid" : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: _selectedBloodGroup,
          decoration: const InputDecoration(
            labelText: 'Blood Group',
            prefixIcon: Icon(Icons.bloodtype_outlined),
            border: OutlineInputBorder(),
          ),
          items: _bloodGroups.map((group) {
            return DropdownMenuItem(
              value: group,
              child: Text(group),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedBloodGroup = val);
            }
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _allergiesController,
          decoration: const InputDecoration(
            labelText: 'Food & Medicine Allergies',
            hintText: 'e.g. Penicillin, Peanuts (comma separated)',
            prefixIcon: Icon(Icons.warning_amber_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Undergoing Treatment Switch
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Undergoing Medical Treatment?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: const Text("Toggle if you have active chronic illnesses", style: TextStyle(fontSize: 11)),
          value: _undergoingTreatment,
          activeColor: AppTheme.primaryGreen,
          onChanged: (val) {
            setState(() => _undergoingTreatment = val);
          },
        ),

        if (_undergoingTreatment) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _diseaseController,
            decoration: const InputDecoration(
              labelText: 'Diagnosed Disease / Condition',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (_undergoingTreatment && (v == null || v.isEmpty)) ? "Please specify condition" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _doctorController,
            decoration: const InputDecoration(
              labelText: 'Consulting Doctor & Hospital',
              border: OutlineInputBorder(),
            ),
          ),
        ],

        const Divider(height: 36),
        const Text(
          "Emergency Contact",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _contactNameController,
          decoration: const InputDecoration(
            labelText: 'Contact Name',
            prefixIcon: Icon(Icons.contact_phone_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contactPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Contact Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
        ),
      ],
    );
  }
}
