import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../models/number_guess_state.dart';

class NgResultOverlay extends StatefulWidget {
  final GameStatus status;
  final int score;
  final int secretNumber;
  final int totalGuesses;
  final VoidCallback onPlayAgain;

  const NgResultOverlay({
    super.key,
    required this.status,
    required this.score,
    required this.secretNumber,
    required this.totalGuesses,
    required this.onPlayAgain,
  });

  @override
  State<NgResultOverlay> createState() => _NgResultOverlayState();
}

class _NgResultOverlayState extends State<NgResultOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isWin => widget.status == GameStatus.won;

  Color get _accentColor =>
      _isWin ? const Color(0xFF4CAF82) : const Color(0xFFE05C5C);

  String get _emoji => _isWin ? '🎉' : '😔';
  String get _title => _isWin ? 'You cracked it!' : 'Better luck next time';
  String get _subtitle => _isWin
      ? 'The number was ${widget.secretNumber}. Solved in ${widget.totalGuesses} guess${widget.totalGuesses == 1 ? '' : 'es'}.'
      : 'The number was ${widget.secretNumber}. You ran out of attempts.';

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: AppTheme.bg.withOpacity(0.96),
        child: SafeArea(
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Emoji ──
                  Text(_emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 24),

                  // ── Title ──
                  Text(
                    _title,
                    style: AppTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _subtitle,
                    style: AppTheme.cardBody.copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // ── Score card ──
                  if (_isWin) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 20),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _accentColor.withOpacity(0.25)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${widget.score}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: _accentColor,
                              letterSpacing: -2,
                            ),
                          ),
                          Text(
                            'points',
                            style:
                                AppTheme.cardBody.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // ── Play again ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.ink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: widget.onPlayAgain,
                      child: const Text(
                        'Play again',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Back home ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.ink,
                        side: const BorderSide(color: AppTheme.inkFaint),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => context.go('/'),
                      child: const Text(
                        'Back to home',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
