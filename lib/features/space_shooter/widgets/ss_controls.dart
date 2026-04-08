import 'package:flutter/material.dart';

/// Full-canvas gesture zone.
/// Left half  → move left while finger is down.
/// Right half → move right while finger is down.
/// Renders a subtle tap-ripple hint so the player knows where they tapped.
class SsControls extends StatefulWidget {
  final VoidCallback onLeftStart;
  final VoidCallback onLeftEnd;
  final VoidCallback onRightStart;
  final VoidCallback onRightEnd;

  const SsControls({
    super.key,
    required this.onLeftStart,
    required this.onLeftEnd,
    required this.onRightStart,
    required this.onRightEnd,
  });

  @override
  State<SsControls> createState() => _SsControlsState();
}

class _SsControlsState extends State<SsControls>
    with SingleTickerProviderStateMixin {
  bool _leftActive  = false;
  bool _rightActive = false;

  // Ripple feedback
  late final AnimationController _rippleCtrl;
  late final Animation<double>    _rippleAnim;
  Offset? _ripplePos;

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rippleAnim = CurvedAnimation(
      parent: _rippleCtrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    super.dispose();
  }

  void _onDown(Offset localPos, Size size) {
    final isLeft = localPos.dx < size.width / 2;
    setState(() {
      _leftActive  = isLeft;
      _rightActive = !isLeft;
      _ripplePos   = localPos;
    });
    _rippleCtrl.forward(from: 0);

    if (isLeft) {
      widget.onLeftStart();
    } else {
      widget.onRightStart();
    }
  }

  void _onMove(Offset localPos, Size size) {
    final isLeft = localPos.dx < size.width / 2;
    if (isLeft && !_leftActive) {
      widget.onRightEnd();
      widget.onLeftStart();
      setState(() { _leftActive = true; _rightActive = false; });
    } else if (!isLeft && !_rightActive) {
      widget.onLeftEnd();
      widget.onRightStart();
      setState(() { _leftActive = false; _rightActive = true; });
    }
  }

  void _onUp() {
    widget.onLeftEnd();
    widget.onRightEnd();
    setState(() { _leftActive = false; _rightActive = false; });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart:  (d) => _onDown(d.localPosition, size),
          onPanUpdate: (d) => _onMove(d.localPosition, size),
          onPanEnd:    (_) => _onUp(),
          onPanCancel: ()  => _onUp(),
          // Also catch plain taps (no drag)
          onTapDown:   (d) => _onDown(d.localPosition, size),
          onTapUp:     (_) => _onUp(),
          onTapCancel: ()  => _onUp(),
          child: Stack(
            children: [
              // ── Left zone hint ──────────────────────────────────
              AnimatedOpacity(
                opacity: _leftActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 120),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: size.width / 2,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x18FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: const Align(
                      alignment: Alignment(-.6, .7),
                      child: _DirectionHint(icon: Icons.chevron_left_rounded),
                    ),
                  ),
                ),
              ),

              // ── Right zone hint ─────────────────────────────────
              AnimatedOpacity(
                opacity: _rightActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 120),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: size.width / 2,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x00FFFFFF),
                          Color(0x18FFFFFF),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: const Align(
                      alignment: Alignment(.6, .7),
                      child: _DirectionHint(icon: Icons.chevron_right_rounded),
                    ),
                  ),
                ),
              ),

              // ── Tap ripple ──────────────────────────────────────
              if (_ripplePos != null)
                AnimatedBuilder(
                  animation: _rippleAnim,
                  builder: (_, __) {
                    final r = _rippleAnim.value * 48;
                    final opacity = (1 - _rippleAnim.value) * 0.4;
                    return CustomPaint(
                      painter: _RipplePainter(
                        center: _ripplePos!,
                        radius: r,
                        opacity: opacity,
                      ),
                      size: size,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Direction chevron shown when zone is active ───────────────────────────────

class _DirectionHint extends StatelessWidget {
  final IconData icon;
  const _DirectionHint({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Icon(icon, color: Colors.white54, size: 28),
    );
  }
}

// ── Ripple painter ────────────────────────────────────────────────────────────

class _RipplePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double opacity;

  const _RipplePainter({
    required this.center,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || radius <= 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.radius != radius || old.opacity != opacity;
}
