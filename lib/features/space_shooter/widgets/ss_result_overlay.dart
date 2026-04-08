import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../engine/ss_engine.dart';

class SsResultOverlay extends StatefulWidget {
  final SpaceShooterEngine engine;
  final VoidCallback onPlayAgain;

  const SsResultOverlay({
    super.key,
    required this.engine,
    required this.onPlayAgain,
  });

  @override
  State<SsResultOverlay> createState() => _SsResultOverlayState();
}

class _SsResultOverlayState extends State<SsResultOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.engine;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: const Color(0xF0060912),
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Icon ──
                  Text(
                    e.phase == GamePhase.paused ? '⏸' : '💥',
                    style: const TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 12),

                  // ── Title ──
                  Text(
                    e.phase == GamePhase.paused ? 'Paused' : 'Game Over',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (e.phase == GamePhase.gameOver) ...[
                    Text(
                      'You survived ${e.wave - 1} wave${e.wave == 2 ? '' : 's'} and scored:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // ── Score card ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${e.score}',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFD600),
                              letterSpacing: -2,
                            ),
                          ),
                          Text(
                            'pts · ${e.kills} kills',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox(height: 36),
                  ],

                  // ── Play again / resume ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF060912),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: widget.onPlayAgain,
                      child: Text(
                        e.phase == GamePhase.paused ? 'Resume' : 'Play again',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Home ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.2)),
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
