import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import 'clay_container.dart';

/// Large, easy-to-tap button designed for elderly shop owner.
class BigButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;

  const BigButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = foregroundColor ?? Colors.white;

    return SizedBox(
      height: height,
      child: ClayContainer(
        borderRadius: 16,
        color: bg,
        onTap: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 28),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: AppTypography.buttonLarge.copyWith(color: fg, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
