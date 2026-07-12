import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../core/constants/mock_data.dart';
import 'package:intl/intl.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/firebase_storage_service.dart';
import '../../services/ai_gemini_service.dart';
import '../../services/firestore_service.dart';
import '../../models/prescription_model.dart';
import '../../models/medicine_model.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({Key? key}) : super(key: key);

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = MediVaultRepository();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _doctorController;
  late TextEditingController _totalQtyController;
  late TextEditingController _dailyUsageController;
  late TextEditingController _hospitalController;
  
  // Form Fields
  String _name = "";
  String _dosage = "1 Tablet";
  String _time = "08:00 AM";
  String _frequency = "Daily";
  bool _beforeFood = false;
  bool _isPrescribed = true;
  String _doctorName = "";
  int _totalQty = 30;
  int _remainingQty = 30;
  int _dailyUsage = 1;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 180));
  String _selectedIcon = 'pill';

  // supplementary states
  File? _prescriptionImage;
  bool _isOcrLoading = false;
  bool _isSaving = false;
  DateTime _consultationDate = DateTime.now();
  int _daysPurchased = 30;
  String _prescriptionDescription = "";

  final List<String> _iconOptions = ['pill', 'tablet', 'capsule'];
  final List<String> _frequencies = ['Daily', 'Twice Daily', 'Three Times Daily', 'Weekly'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dosageController = TextEditingController(text: "1 Tablet");
    _doctorController = TextEditingController();
    _totalQtyController = TextEditingController(text: "30");
    _dailyUsageController = TextEditingController(text: "1");
    _hospitalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _doctorController.dispose();
    _totalQtyController.dispose();
    _dailyUsageController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _time = picked.format(context);
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickPrescriptionImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _prescriptionImage = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _runAIOcr() async {
    if (_prescriptionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select or snap a prescription image first.")),
      );
      return;
    }

    setState(() => _isOcrLoading = true);
    try {
      final results = await AIGeminiService().readPrescription(_prescriptionImage!);
      
      setState(() {
        _nameController.text = results['medicineName'] ?? '';
        _dosageController.text = results['dosage'] ?? '1 Tablet';
        _doctorController.text = results['doctorName'] ?? '';
        _time = results['time'] ?? '08:00 AM';
        _frequency = results['frequency'] ?? 'Daily';
        _beforeFood = results['beforeFood'] ?? false;
        
        _daysPurchased = results['durationDays'] ?? 30;
        _totalQtyController.text = (_daysPurchased * int.parse(_dailyUsageController.text)).toString();
        _prescriptionDescription = results['explanation'] ?? '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AI Auto-filled fields successfully! Verify details below."),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint("OCR fill error: $e");
    } finally {
      if (mounted) {
        setState(() => _isOcrLoading = false);
      }
    }
  }

  void _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSaving = true);

      try {
        final String prescId = 'presc_${DateTime.now().millisecondsSinceEpoch}';
        String? imageUrl;
        
        if (_prescriptionImage != null) {
          imageUrl = await FirebaseStorageService().uploadPrescriptionImage(prescId, _prescriptionImage!);
          
          final prescModel = PrescriptionModel(
            id: prescId,
            doctorName: _isPrescribed ? _doctorController.text.trim() : "Over The Counter",
            dateString: DateFormat('MMM dd, yyyy').format(_consultationDate),
            diagnosis: "Medication Reminders Setup",
            notes: _prescriptionDescription.isNotEmpty ? _prescriptionDescription : "Uploaded via Add Medication",
            isAIAnalyzed: true,
            simplifiedMedicines: ["${_nameController.text} - ${_dosageController.text} $_frequency"],
            imageUrl: imageUrl,
            consultationDate: _consultationDate,
            hospital: _hospitalController.text.trim(),
            daysPurchased: _daysPurchased,
            uploadDate: DateTime.now(),
            description: _prescriptionDescription,
          );

          await FirestoreService().savePrescription(prescModel);
        }

        final newMed = Medicine(
          id: 'med_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          time: _time,
          frequency: _frequency,
          beforeFood: _beforeFood,
          isPrescribed: _isPrescribed,
          doctorName: _isPrescribed ? _doctorController.text.trim() : null,
          totalQuantity: int.parse(_totalQtyController.text),
          remainingQuantity: int.parse(_totalQtyController.text),
          dailyUsage: int.parse(_dailyUsageController.text),
          expiryDate: _expiryDate,
          iconName: _selectedIcon,
        );

        _repository.addMedicine(newMed);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Medication added and reminder scheduled!"),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving medication: $e"), backgroundColor: AppTheme.statusRed),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Medicine"),
      ),
      body: GradientBackground(
        style: BackgroundStyle.pillPattern,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Medication Information",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Divider(height: 20),

                      // Name input
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Medicine Name',
                          hintText: 'e.g. Paracetamol, Metformin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medication),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? "Please enter a name" : null,
                      ),
                      const SizedBox(height: 16),

                      // Dosage & Icon Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dosageController,
                              decoration: const InputDecoration(
                                labelText: 'Dosage',
                                hintText: 'e.g. 1 Tablet, 5ml',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedIcon,
                              decoration: const InputDecoration(
                                labelText: 'Type Icon',
                                border: OutlineInputBorder(),
                              ),
                              items: _iconOptions.map((icon) {
                                return DropdownMenuItem(
                                  value: icon,
                                  child: Text(icon[0].toUpperCase() + icon.substring(1)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedIcon = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Time & Frequency
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Reminder Time',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.alarm),
                                ),
                                child: Text(_time),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _frequency,
                              decoration: const InputDecoration(
                                labelText: 'Frequency',
                                border: OutlineInputBorder(),
                              ),
                              items: _frequencies.map((freq) {
                                return DropdownMenuItem(
                                  value: freq,
                                  child: Text(freq),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _frequency = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Before / After food toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Food Relation:", style: TextStyle(fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text("Before Food"),
                                selected: _beforeFood,
                                selectedColor: Colors.orange.withAlpha(50),
                                labelStyle: TextStyle(color: _beforeFood ? Colors.orange : Colors.grey, fontWeight: FontWeight.bold),
                                onSelected: (selected) {
                                  setState(() => _beforeFood = true);
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text("After Food"),
                                selected: !_beforeFood,
                                selectedColor: Colors.blue.withAlpha(50),
                                labelStyle: TextStyle(color: !_beforeFood ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold),
                                onSelected: (selected) {
                                  setState(() => _beforeFood = false);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Prescribed / Non-Prescribed
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Prescription Status:", style: TextStyle(fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text("Prescribed"),
                                selected: _isPrescribed,
                                selectedColor: AppTheme.primaryGreen.withAlpha(50),
                                labelStyle: TextStyle(color: _isPrescribed ? AppTheme.primaryGreen : Colors.grey, fontWeight: FontWeight.bold),
                                onSelected: (selected) {
                                  setState(() => _isPrescribed = true);
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text("Over The Counter"),
                                selected: !_isPrescribed,
                                selectedColor: Colors.grey.withAlpha(50),
                                labelStyle: TextStyle(color: !_isPrescribed ? (isDark ? Colors.white : Colors.black) : Colors.grey),
                                onSelected: (selected) {
                                  setState(() => _isPrescribed = false);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      
                      if (_isPrescribed) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _doctorController,
                          decoration: const InputDecoration(
                            labelText: 'Prescribing Doctor Name',
                            hintText: 'e.g. Dr. Jenkins',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => (_isPrescribed && (value == null || value.isEmpty)) ? "Please enter doctor's name" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _hospitalController,
                          decoration: const InputDecoration(
                            labelText: 'Hospital / Clinic',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_hospital_outlined),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Inventory & Expiry Management",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Divider(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _totalQtyController,
                              decoration: const InputDecoration(
                                labelText: 'Total Count Purchased',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => int.tryParse(v ?? "") == null ? "Required number" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _dailyUsageController,
                              decoration: const InputDecoration(
                                labelText: 'Daily Usage (Pills/Day)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => int.tryParse(v ?? "") == null ? "Required number" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _selectExpiryDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.date_range),
                          ),
                          child: Text(DateFormat('yyyy-MM-dd').format(_expiryDate)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Prescription image upload
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Prescription Image (Optional)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Attach a photo of the prescription for your records. AI will auto-fill fields.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Divider(height: 20),
                      if (_prescriptionImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_prescriptionImage!, height: 160, width: double.infinity, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 12),
                        if (_isOcrLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _runAIOcr,
                            icon: const Icon(Icons.psychology, size: 16),
                            label: const Text("AI Auto-Fill Fields"),
                          ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickPrescriptionImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined, size: 18),
                              label: const Text("Camera"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickPrescriptionImage(ImageSource.gallery),
                              icon: const Icon(Icons.image_outlined, size: 18),
                              label: const Text("Gallery"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isSaving ? null : _saveMedication,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Save Medication", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
