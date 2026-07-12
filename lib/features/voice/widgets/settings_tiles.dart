// ──────────────────────────────────────────────────────────
// VOICE SETTINGS SHARED WIDGETS
// Premium reusable tiles for the voice reminder settings page.
// ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';

// ═══════════════════════════════════════════════════════════
// 1. SETTINGS SECTION HEADER
//    Groups a set of related tiles with an icon, title, and
//    optional subtitle.
// ═══════════════════════════════════════════════════════════

class SettingsSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;

  const SettingsSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 2. SWITCH SETTINGS TILE
//    A single row with label, optional description, and a Switch.
// ═══════════════════════════════════════════════════════════

class SwitchSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accentColor;
  final bool isEnabled;

  const SwitchSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
    this.accentColor = AppTheme.primaryGreen,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (value ? accentColor : Colors.grey).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? accentColor : Colors.grey,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isEnabled ? null : Colors.grey,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
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
          Switch(
            value: value,
            activeThumbColor: accentColor,
            onChanged: isEnabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 3. SLIDER SETTINGS TILE
//    A card with label, value display, and a Slider.
//    Shows optional min/max labels.
// ═══════════════════════════════════════════════════════════

class SliderSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? valueLabel;
  final ValueChanged<double> onChanged;
  final Color accentColor;
  final String? minLabel;
  final String? maxLabel;
  final bool isEnabled;

  const SliderSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.valueLabel,
    required this.onChanged,
    this.accentColor = AppTheme.primaryGreen,
    this.minLabel,
    this.maxLabel,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayValue =
        valueLabel != null ? valueLabel!(value) : value.toStringAsFixed(1);

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isEnabled ? null : Colors.grey,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description!,
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
              // Current value badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          // ── Slider row ──
          Row(
            children: [
              if (minLabel != null)
                Text(minLabel!,
                    style: const TextStyle(fontSize: 9, color: Colors.grey)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accentColor,
                    inactiveTrackColor: accentColor.withAlpha(30),
                    thumbColor: accentColor,
                    overlayColor: accentColor.withAlpha(25),
                    trackHeight: 3.5,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: value.clamp(min, max),
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: isEnabled ? onChanged : null,
                  ),
                ),
              ),
              if (maxLabel != null)
                Text(maxLabel!,
                    style: const TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 4. DROPDOWN SETTINGS TILE
//    A card wrapping a DropdownButton for single-option selection.
// ═══════════════════════════════════════════════════════════

class DropdownSettingsTile<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Color accentColor;
  final bool isEnabled;

  const DropdownSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.value,
    required this.items,
    required this.onChanged,
    this.accentColor = AppTheme.primaryGreen,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (description != null)
                  Text(
                    description!,
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withAlpha(8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withAlpha(18),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isDense: true,
                borderRadius: BorderRadius.circular(12),
                items: items,
                onChanged: isEnabled ? onChanged : null,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 5. TEXT FIELD SETTINGS TILE
//    Inline editable text field for greeting messages.
// ═══════════════════════════════════════════════════════════

class TextFieldSettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String initialValue;
  final String hintText;
  final int maxLines;
  final ValueChanged<String> onChanged;
  final Color accentColor;
  final bool isEnabled;

  const TextFieldSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.initialValue,
    required this.hintText,
    this.maxLines = 2,
    required this.onChanged,
    this.accentColor = AppTheme.primaryGreen,
    this.isEnabled = true,
  });

  @override
  State<TextFieldSettingsTile> createState() => _TextFieldSettingsTileState();
}

class _TextFieldSettingsTileState extends State<TextFieldSettingsTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon,
                    color: widget.accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: widget.maxLines,
            enabled: widget.isEnabled,
            onChanged: widget.onChanged,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor:
                  (isDark ? Colors.white : Colors.black).withAlpha(8),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: widget.accentColor.withAlpha(40)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color:
                        (isDark ? Colors.white : Colors.black).withAlpha(20)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: widget.accentColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 6. TIME RANGE TILE
//    Two time pickers side by side (for silent mode).
// ═══════════════════════════════════════════════════════════

class TimeRangeSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;
  final Color accentColor;
  final bool isEnabled;

  const TimeRangeSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.onStartChanged,
    required this.onEndChanged,
    this.accentColor = Colors.indigo,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isEnabled ? null : Colors.grey,
                        )),
                    if (description != null)
                      Text(description!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Time pickers row
          Row(
            children: [
              Expanded(
                child: _TimePicker(
                  label: 'Start',
                  time: startTime,
                  accentColor: accentColor,
                  isEnabled: isEnabled,
                  onPick: (picked) => onStartChanged(picked),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward_rounded,
                    color: Colors.grey, size: 18),
              ),
              Expanded(
                child: _TimePicker(
                  label: 'End',
                  time: endTime,
                  accentColor: accentColor,
                  isEnabled: isEnabled,
                  onPick: (picked) => onEndChanged(picked),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final Color accentColor;
  final bool isEnabled;
  final ValueChanged<TimeOfDay> onPick;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.accentColor,
    required this.isEnabled,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatted = time.format(context);

    return GestureDetector(
      onTap: isEnabled
          ? () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: accentColor,
                      brightness: isDark
                          ? Brightness.dark
                          : Brightness.light,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onPick(picked);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: accentColor.withAlpha(isEnabled ? 20 : 10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: accentColor.withAlpha(isEnabled ? 60 : 20)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isEnabled ? accentColor : Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14,
                    color: isEnabled ? accentColor : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  formatted,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isEnabled ? accentColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 7. INFO / HINT TILE
//    Non-interactive banner for integration notes.
// ═══════════════════════════════════════════════════════════

class InfoSettingsTile extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const InfoSettingsTile({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.color = AppTheme.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
