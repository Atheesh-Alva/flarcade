import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class NgNumberInput extends StatefulWidget {
  final int value;
  final bool enabled;
  final ValueChanged<int> onAdjust;   // +1 or -1 from stepper buttons
  final ValueChanged<int> onChanged;  // raw value from text field
  final VoidCallback onSubmit;

  const NgNumberInput({
    super.key,
    required this.value,
    required this.enabled,
    required this.onAdjust,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  State<NgNumberInput> createState() => _NgNumberInputState();
}

class _NgNumberInputState extends State<NgNumberInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(NgNumberInput old) {
    super.didUpdateWidget(old);
    // Sync only if the value changed externally (stepper press)
    if (old.value != widget.value) {
      final text = '${widget.value}';
      if (_ctrl.text != text) {
        _ctrl.text = text;
        _ctrl.selection = TextSelection.collapsed(offset: text.length);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // ── Range hint ──
          Text(
            'Choose a number between 1 and 100',
            style: AppTheme.cardBody.copyWith(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // ── Stepper row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(
                label: '−',
                enabled: widget.enabled && widget.value > 1,
                onTap: () => widget.onAdjust(-1),
              ),
              const SizedBox(width: 16),

              // Number input
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _ctrl,
                  enabled: widget.enabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                    letterSpacing: -1,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.inkFaint),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.inkFaint),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppTheme.accent, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: AppTheme.surface,
                  ),
                  onChanged: (v) {
                    final parsed = int.tryParse(v);
                    if (parsed != null) widget.onChanged(parsed);
                  },
                  onSubmitted: (_) => widget.onSubmit(),
                ),
              ),

              const SizedBox(width: 16),
              _StepButton(
                label: '+',
                enabled: widget.enabled && widget.value < 100,
                onTap: () => widget.onAdjust(1),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Submit ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.enabled ? AppTheme.ink : AppTheme.inkFaint,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: widget.enabled ? widget.onSubmit : null,
              child: const Text(
                'Submit guess',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.surface : AppTheme.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? AppTheme.inkFaint : AppTheme.inkFaint,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: enabled ? AppTheme.ink : AppTheme.inkFaint,
            ),
          ),
        ),
      ),
    );
  }
}
