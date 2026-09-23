import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Claymorphic container with soft tactile dual shadows and rounded borders.
class ClayContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;
  final VoidCallback? onTap;
  final double depth;

  const ClayContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = 20,
    this.onTap,
    this.depth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = color ?? AppColors.surface;

    Widget container = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.clayBorder, width: 1.5),
        boxShadow: [
          // Soft bottom-right dark shadow
          BoxShadow(
            color: AppColors.clayDarkShadow.withValues(alpha: 0.5 * depth),
            offset: Offset(6 * depth, 6 * depth),
            blurRadius: 12 * depth,
            spreadRadius: 0,
          ),
          // Soft top-left light highlight shadow
          BoxShadow(
            color: AppColors.clayLightShadow.withValues(alpha: 0.9),
            offset: Offset(-4 * depth, -4 * depth),
            blurRadius: 10 * depth,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }

    return container;
  }
}
