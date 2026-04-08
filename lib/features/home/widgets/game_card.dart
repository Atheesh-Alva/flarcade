import 'package:flutter/material.dart';
import 'package:flutter_arcade/core/models/difficulty.dart';
import '../../../core/models/game_info.dart';
import '../../../core/theme/app_theme.dart';
import 'game_bottom_sheet.dart';

class GameCard extends StatefulWidget {
  final GameInfo game;
  final int index;

  const GameCard({super.key, required this.game, required this.index});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(
      Duration(milliseconds: 40 + widget.index * 50),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final diffColor = game.difficulty.color;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            _openSheet(context);
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.inkFaint),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.ink.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Emoji ──
                  Text(
                    game.emoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                  const Spacer(),

                  // ── Title ──
                  Text(
                    game.title,
                    style: AppTheme.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // ── Description ──
                  Text(
                    game.description,
                    style: AppTheme.cardBody,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),

                  // ── Footer ──
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: diffColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        game.difficulty.label,
                        style: AppTheme.tagLabel.copyWith(
                          color: diffColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppTheme.inkMuted.withOpacity(0.4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GameBottomSheet(game: widget.game),
    );
  }
}
