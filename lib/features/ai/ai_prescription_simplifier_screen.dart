import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../core/constants/mock_data.dart';

class AIPrescriptionSimplifierScreen extends StatefulWidget {
  const AIPrescriptionSimplifierScreen({Key? key}) : super(key: key);

  @override
  State<AIPrescriptionSimplifierScreen> createState() => _AIPrescriptionSimplifierScreenState();
}

class _AIPrescriptionSimplifierScreenState extends State<AIPrescriptionSimplifierScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;
  
  bool _hasUploaded = false;
  bool _isAnalyzing = false;
  bool _analysisComplete = false;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _simulateUpload() {
    setState(() {
      _hasUploaded = true;
      _analysisComplete = false;
    });
  }

  void _runAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });
    _scannerController.repeat(reverse: true);
    
    // Simulate AI reading details
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisComplete = true;
        });
        _scannerController.stop();
      }
    });
  }

  void _addToVaultAndSchedule() {
    final repo = MediVaultRepository();
    
    // 1. Add to Prescription Vault
    final newPrescription = PrescriptionVaultItem(
      id: 'p_ai_${DateTime.now().millisecondsSinceEpoch}',
      doctorName: 'Dr. John Watson (AI Extracted)',
      dateString: 'Today (AI Extracted)',
      diagnosis: 'Type 2 Diabetes Control',
      notes: 'Take Metformin twice daily with meals.',
      isAIAnalyzed: true,
      simplifiedMedicines: ['Metformin HCl - 500mg twice daily with meals to stabilize blood sugars'],
    );
    repo.uploadPrescription(newPrescription);

    // 2. Add to active medicines list
    final newMed = Medicine(
      id: 'med_ai_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Metformin (AI Extracted)',
      dosage: '500 mg',
      time: '01:00 PM',
      frequency: 'Twice Daily',
      beforeFood: false,
      isPrescribed: true,
      doctorName: 'Dr. John Watson',
      totalQuantity: 60,
      remainingQuantity: 60,
      dailyUsage: 2,
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      iconName: 'tablet',
    );
    repo.addMedicine(newMed);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Prescription saved to vault and Metformin added to schedule!"),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Prescription Simplifier"),
      ),
      body: GradientBackground(
        style: BackgroundStyle.aiStars,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Document Upload section
              if (!_hasUploaded) _buildUploadPlaceholder() else _buildDocumentPreview(),
              
              const SizedBox(height: 24),
              
              // 2. Analysis results
              if (_isAnalyzing) _buildAnalyzingState(),
              if (_analysisComplete) _buildAnalysisResults(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.document_scanner_rounded, size: 64, color: AppTheme.primaryGreen),
          const SizedBox(height: 16),
          const Text(
            "Upload Prescription",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          const Text(
            "Take a picture or select a PDF of your doctor's handwritten prescription. Our medical AI will simplify it for you.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUploadOption(Icons.camera_alt_outlined, "Camera"),
              _buildUploadOption(Icons.image_outlined, "Gallery"),
              _buildUploadOption(Icons.picture_as_pdf_outlined, "PDF Document"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUploadOption(IconData icon, String label) {
    return InkWell(
      onTap: _simulateUpload,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryGreen.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 24),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Stack(
            children: [
              // Simulated image document preview
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(40),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withAlpha(100)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("rx_prescription_july_11.jpg", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Text("File size: 1.2 MB", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              
              // Scanner horizontal laser line
              if (_isAnalyzing)
                AnimatedBuilder(
                  animation: _scannerAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scannerAnimation.value * 180,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withAlpha(200),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _hasUploaded = false;
                    _analysisComplete = false;
                  });
                },
                child: const Text("Delete & Reupload", style: TextStyle(color: AppTheme.statusRed)),
              ),
              if (!_analysisComplete && !_isAnalyzing)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _runAnalysis,
                  icon: const Icon(Icons.psychology, size: 16),
                  label: const Text("AI Simplification"),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return GlassCard(
      margin: const EdgeInsets.only(top: 16),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen)),
              SizedBox(height: 16),
              Text("AI is extracting text, dosage schedules, and health notes...", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "AI Simplified Prescription Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultRow("Medicine Name", "Metformin Hydrochloride", isTitle: true),
              _buildResultRow("Purpose", "Treat type 2 diabetes by stabilizing blood sugar glucose."),
              _buildResultRow("Dosage", "500 mg tablets"),
              _buildResultRow("Timing", "01:00 PM (After Lunch) and 08:00 PM (After Dinner)"),
              _buildResultRow("Food Relation", "Take strictly AFTER food to prevent stomach upset"),
              _buildResultRow("Side Effects", "Mild bloating, gas, temporary diarrhea, metallic taste"),
              _buildResultRow("Precautions", "Check HbA1c levels, monitor kidney functions yearly, limit alcohol."),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _addToVaultAndSchedule,
          icon: const Icon(Icons.save),
          label: const Text("Add to Vault & Medicine Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildResultRow(String label, String value, {bool isTitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: isTitle ? 16 : 14,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}
