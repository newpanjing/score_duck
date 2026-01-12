import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScoreFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLandscape;

  const ScoreFloatingActionButton({super.key, required this.onPressed, required this.isLandscape});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: isLandscape ? 32 : 44,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(CupertinoIcons.add, color: CupertinoColors.white, size: 32),
        ),
      ),
    );
  }
}

class ScoreStepper extends StatelessWidget {
  final int value;
  final int step;
  final ValueChanged<int> onChanged;
  final bool isScore;

  const ScoreStepper({
    super.key,
    required this.value,
    this.step = 1,
    required this.onChanged,
    this.isScore = false,
  });

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);
    final color = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StepBtn(icon: CupertinoIcons.minus, onTap: () => onChanged(value - step)),
          Container(
            width: isScore ? 70 : 44,
            alignment: Alignment.center,
            child: Text(
              isScore && value > 0 ? '+$value' : '$value',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isScore
                    ? (value >= 0 ? CupertinoColors.activeBlue : CupertinoColors.systemRed)
                    : null,
              ),
            ),
          ),
          StepBtn(icon: CupertinoIcons.plus, onTap: () => onChanged(value + step)),
        ],
      ),
    );
  }
}

class StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const StepBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A3A3C) : CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
