import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../core/constants/mock_data.dart';
import 'package:intl/intl.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = MediVaultRepository();

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

  final List<String> _iconOptions = ['pill', 'tablet', 'capsule'];
  final List<String> _frequencies = ['Daily', 'Twice Daily', 'Three Times Daily', 'Weekly'];

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

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newMed = Medicine(
        id: 'med_${DateTime.now().millisecondsSinceEpoch}',
        name: _name,
        dosage: _dosage,
        time: _time,
        frequency: _frequency,
        beforeFood: _beforeFood,
        isPrescribed: _isPrescribed,
        doctorName: _isPrescribed ? _doctorName : null,
        totalQuantity: _totalQty,
        remainingQuantity: _remainingQty,
        dailyUsage: _dailyUsage,
        expiryDate: _expiryDate,
        iconName: _selectedIcon,
      );

      _repository.addMedicine(newMed);
      Navigator.pop(context);
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
                        decoration: const InputDecoration(
                          labelText: 'Medicine Name',
                          hintText: 'e.g. Paracetamol, Metformin',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medication),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? "Please enter a name" : null,
                        onSaved: (value) => _name = value ?? "",
                      ),
                      const SizedBox(height: 16),

                      // Dosage & Icon Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _dosage,
                              decoration: const InputDecoration(
                                labelText: 'Dosage',
                                hintText: 'e.g. 1 Tablet, 5ml',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
                              onSaved: (value) => _dosage = value ?? "",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedIcon,
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
                              initialValue: _frequency,
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
                          decoration: const InputDecoration(
                            labelText: 'Prescribing Doctor Name',
                            hintText: 'e.g. Dr. Jenkins',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => (_isPrescribed && (value == null || value.isEmpty)) ? "Please enter doctor's name" : null,
                          onSaved: (value) => _doctorName = value ?? "",
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
                              initialValue: "30",
                              decoration: const InputDecoration(
                                labelText: 'Total Count Purchased',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => int.tryParse(v ?? "") == null ? "Required number" : null,
                              onSaved: (v) {
                                _totalQty = int.parse(v!);
                                _remainingQty = _totalQty; // default initial stock
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: "1",
                              decoration: const InputDecoration(
                                labelText: 'Daily Usage (Pills/Day)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => int.tryParse(v ?? "") == null ? "Required number" : null,
                              onSaved: (v) => _dailyUsage = int.parse(v!),
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

                const SizedBox(height: 28),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _saveMedication,
                  child: const Text("Save Medication", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
