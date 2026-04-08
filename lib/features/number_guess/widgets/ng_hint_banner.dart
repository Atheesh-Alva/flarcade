import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/guess_result.dart';

class NgHintBanner extends StatelessWidget {
  final GuessResult? lastGuess;

  const NgHintBanner({super.key, required this.lastGuess});

  @override
  Widget build(BuildContext context) {
    if (lastGuess == null) {
      return const _PlaceholderBanner();
    }
    return _HintCard(result: lastGuess!);
  }
}

class _PlaceholderBanner extends StatelessWidget {
  const _PlaceholderBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.inkFaint),
      ),
      child: const Center(
        child: Text(
          'Make your first guess!',
          style: AppTheme.cardBody,
        ),
      ),
    );
  }
}

class _HintCard extends StatefulWidget {
  final GuessResult result;
  const _HintCard({required this.result});

  @override
  State<_HintCard> createState() => _HintCardState();
}

class _HintCardState extends State<_HintCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.result.hint) {
      case GuessHint.tooHigh: return const Color(0xFFE05C5C);
      case GuessHint.tooLow:  return const Color(0xFFE8A838);
      case GuessHint.correct: return const Color(0xFF4CAF82);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 88,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: _bgColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bgColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.result.hint.arrow,
                style: TextStyle(
                  fontSize: 28,
                  color: _bgColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.result.hint.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _bgColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Your guess: ${widget.result.value}',
                    style: AppTheme.cardBody,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
