import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GameSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const GameSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.inkFaint),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          color: AppTheme.ink,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppTheme.accent,
        decoration: InputDecoration(
          hintText: 'Search games…',
          hintStyle: TextStyle(
            color: AppTheme.inkMuted.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.inkMuted.withOpacity(0.5),
            size: 19,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}
