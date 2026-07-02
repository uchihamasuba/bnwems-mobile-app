import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? radius;
  final bool hasBorder;

  const InfoCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.radius,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(AppSizes.cardPadding),
      child: child,
    );

    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(radius ?? AppSizes.radiusLarge),
        border: hasBorder
            ? Border.all(color: borderColor ?? AppColors.divider, width: 1)
            : null,
        boxShadow: AppColors.softShadow,
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius:
                    BorderRadius.circular(radius ?? AppSizes.radiusLarge),
                child: cardContent,
              ),
            )
          : cardContent,
    );
  }
}
