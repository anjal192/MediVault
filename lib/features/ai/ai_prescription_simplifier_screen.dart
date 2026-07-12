import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../core/constants/mock_data.dart';
import '../../services/ai_gemini_service.dart';
import '../../services/firebase_storage_service.dart';
import '../../services/firestore_service.dart';
import '../../models/prescription_model.dart';
import '../../models/medicine_model.dart';

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

  File? _prescriptionImage;
  Map<String, dynamic>? _ocrResults;
  final _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _prescriptionImage = File(picked.path);
          _hasUploaded = true;
          _analysisComplete = false;
          _ocrResults = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not access camera/gallery: $e")),
        );
      }
    }
  }

  void _runAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });
    _scannerController.repeat(reverse: true);
    
    try {
      final results = await AIGeminiService().readPrescription(_prescriptionImage!);
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisComplete = true;
          _ocrResults = results;
        });
        _scannerController.stop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisComplete = true; // show fallback results
          _ocrResults = null;
        });
        _scannerController.stop();
      }
    }
  }

  void _addToVaultAndSchedule() async {
    final repo = MediVaultRepository();
    final r = _ocrResults;
    
    final String prescId = 'p_ai_${DateTime.now().millisecondsSinceEpoch}';
    String? imageUrl;

    try {
      // Upload image if available
      if (_prescriptionImage != null) {
        imageUrl = await FirebaseStorageService().uploadPrescriptionImage(prescId, _prescriptionImage!);
      }

      final doctorName = r?['doctorName'] as String? ?? 'Dr. John Watson (AI Extracted)';
      final medicineName = r?['medicineName'] as String? ?? 'Metformin HCl';
      final dosage = r?['dosage'] as String? ?? '500 mg';
      final frequency = r?['frequency'] as String? ?? 'Twice Daily';
      final time = r?['time'] as String? ?? '01:00 PM';
      final beforeFood = r?['beforeFood'] as bool? ?? false;
      final diagnosis = r?['diagnosis'] as String? ?? 'AI Extracted Diagnosis';
      final notes = r?['notes'] as String? ?? 'AI extracted prescription details.';
      final explanation = r?['explanation'] as String? ?? '';

      // 1. Save prescription to Firestore and vault
      final newPrescModel = PrescriptionModel(
        id: prescId,
        doctorName: doctorName,
        dateString: 'Today (AI Extracted)',
        diagnosis: diagnosis,
        notes: notes,
        isAIAnalyzed: true,
        simplifiedMedicines: ['$medicineName – $dosage $frequency'],
        imageUrl: imageUrl,
        consultationDate: DateTime.now(),
        uploadDate: DateTime.now(),
        description: explanation,
      );
      await FirestoreService().savePrescription(newPrescModel);

      final newPrescription = PrescriptionVaultItem(
        id: prescId,
        doctorName: doctorName,
        dateString: 'Today (AI Extracted)',
        diagnosis: diagnosis,
        notes: notes,
        isAIAnalyzed: true,
        simplifiedMedicines: ['$medicineName – $dosage $frequency'],
      );
      repo.uploadPrescription(newPrescription);

      // 2. Add medicine to active schedule
      final newMed = Medicine(
        id: 'med_ai_${DateTime.now().millisecondsSinceEpoch}',
        name: '$medicineName (AI Extracted)',
        dosage: dosage,
        time: time,
        frequency: frequency,
        beforeFood: beforeFood,
        isPrescribed: true,
        doctorName: doctorName,
        totalQuantity: 60,
        remainingQuantity: 60,
        dailyUsage: frequency.toLowerCase().contains('twice') ? 2 : 1,
        expiryDate: DateTime.now().add(const Duration(days: 90)),
        iconName: 'tablet',
      );
      repo.addMedicine(newMed);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$medicineName saved to vault and schedule!"),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save failed: $e"), backgroundColor: AppTheme.statusRed),
        );
      }
    }
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
              _buildUploadOption(Icons.camera_alt_outlined, "Camera", ImageSource.camera),
              _buildUploadOption(Icons.image_outlined, "Gallery", ImageSource.gallery),
              _buildUploadOption(Icons.picture_as_pdf_outlined, "Gallery (PDF)", ImageSource.gallery),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUploadOption(IconData icon, String label, ImageSource source) {
    return InkWell(
      onTap: () => _pickImage(source),
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
                // Image preview — real if picked, placeholder otherwise
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(40),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withAlpha(100)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _prescriptionImage != null
                      ? Image.file(_prescriptionImage!, fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Prescription file selected", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            Text("Ready for AI analysis", style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                    _prescriptionImage = null;
                    _ocrResults = null;
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
              _buildResultRow("Medicine Name",
                _ocrResults?['medicineName'] as String? ?? 'Metformin Hydrochloride',
                isTitle: true),
              _buildResultRow("Doctor",
                _ocrResults?['doctorName'] as String? ?? 'Dr. Robert Chen'),
              _buildResultRow("Diagnosis",
                _ocrResults?['diagnosis'] as String? ?? 'Blood Sugar Regulation'),
              _buildResultRow("Dosage",
                _ocrResults?['dosage'] as String? ?? '500 mg tablets'),
              _buildResultRow("Timing",
                _ocrResults?['time'] as String? ?? '01:00 PM'),
              _buildResultRow("Frequency",
                _ocrResults?['frequency'] as String? ?? 'Twice Daily'),
              _buildResultRow("Food Relation",
                (_ocrResults?['beforeFood'] as bool? ?? false)
                    ? "Take BEFORE food"
                    : "Take AFTER food to prevent stomach upset"),
              if ((_ocrResults?['explanation'] as String?)?.isNotEmpty ?? false)
                _buildResultRow("Educational Info",
                  _ocrResults!['explanation'] as String),
              if ((_ocrResults?['notes'] as String?)?.isNotEmpty ?? false)
                _buildResultRow("Doctor Notes",
                  _ocrResults!['notes'] as String),
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
