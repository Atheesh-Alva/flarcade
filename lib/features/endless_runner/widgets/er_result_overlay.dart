import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../engine/er_engine.dart';

class ErResultOverlay extends StatefulWidget {
  final EndlessRunnerEngine engine;
  final VoidCallback onPlayAgain;

  const ErResultOverlay({
    super.key,
    required this.engine,
    required this.onPlayAgain,
  });

  @override
  State<ErResultOverlay> createState() => _ErResultOverlayState();
}

class _ErResultOverlayState extends State<ErResultOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  bool get _isPaused => widget.engine.phase == RunnerPhase.paused;

  @override
  Widget build(BuildContext context) {
    final e = widget.engine;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: const Color(0xE8060E1A),
        child: SafeArea(
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    _isPaused ? '⏸' : '💨',
                    style: const TextStyle(fontSize: 52),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    _isPaused ? 'Paused' : 'You tripped!',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (!_isPaused) ...[
                    Text(
                      'Ran ${e.distance.toInt()} metres',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatCard(
                          label: 'Distance',
                          value: '${e.distance.toInt()}m',
                          highlight: true,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Best',
                          value: '${e.bestScore}m',
                          highlight: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ] else
                    const SizedBox(height: 28),

                  // Controls hint
                  if (!_isPaused)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Tap = jump · double tap = double jump\nSwipe up = jump · swipe down = slide',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Play again / resume
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF060E1A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: widget.onPlayAgain,
                      child: Text(
                        _isPaused ? 'Resume' : 'Run again',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => context.go('/'),
                      child: const Text(
                        'Back to home',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: highlight ? Colors.white : Colors.white60,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
