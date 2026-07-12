import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../emergency_sos_mock_data.dart';

/// Emergency instructions section — expandable cards per scenario
/// (Heart Attack, Hypoglycemia, Breathing Difficulty, Allergy).
/// Each card shows step-by-step first-aid instructions.
class EmergencyInstructionsSection extends StatefulWidget {
  final List<EmergencyInstruction> instructions;

  const EmergencyInstructionsSection({
    super.key,
    required this.instructions,
  });

  @override
  State<EmergencyInstructionsSection> createState() =>
      _EmergencyInstructionsSectionState();
}

class _EmergencyInstructionsSectionState
    extends State<EmergencyInstructionsSection> {
  String? _openId; // only one open at a time

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.instructions.map((instr) {
        final isOpen = _openId == instr.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _InstructionCard(
            instruction: instr,
            isOpen: isOpen,
            onToggle: () => setState(() {
              _openId = isOpen ? null : instr.id;
            }),
          ),
        );
      }).toList(),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final EmergencyInstruction instruction;
  final bool isOpen;
  final VoidCallback onToggle;

  const _InstructionCard({
    required this.instruction,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Column(
          children: [
            // ── Header ──
            InkWell(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isOpen
                      ? LinearGradient(
                          colors: [
                            instruction.color.withAlpha(isDark ? 40 : 20),
                            Colors.transparent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: instruction.color.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(instruction.icon,
                          color: instruction.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instruction.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isOpen ? instruction.color : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            instruction.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isOpen ? instruction.color : Colors.grey,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Steps panel ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild:
                  _buildStepsPanel(isDark, instruction),
              crossFadeState: isOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsPanel(
      bool isDark, EmergencyInstruction instruction) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: instruction.color.withAlpha(isDark ? 12 : 6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
              height: 16, color: instruction.color.withAlpha(40)),
          // Call 911 reminder banner
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.statusRed.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppTheme.statusRed.withAlpha(50)),
            ),
            child: const Row(
              children: [
                Icon(Icons.emergency_rounded,
                    color: AppTheme.statusRed, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Always call 911 first — these steps are supplemental.',
                    style: TextStyle(
                      color: AppTheme.statusRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Steps list
          ...instruction.steps.asMap().entries.map((entry) {
            final step = entry.value;
            final num = entry.key + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: instruction.color,
                    ),
                    child: Center(
                      child: Text(
                        '$num',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        step,
                        style: const TextStyle(
                            fontSize: 13, height: 1.4),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
