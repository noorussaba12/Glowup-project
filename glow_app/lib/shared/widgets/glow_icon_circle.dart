import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';

class GlowIconCircle extends ConsumerWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isSelected;

  const GlowIconCircle({
    super.key,
    required this.icon,
    this.label,
    this.onTap,
    this.size = 56,
    this.backgroundColor,
    this.iconColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);

    final bg = isSelected
        ? palette.primaryDark
        : (backgroundColor ?? palette.accentLight);
    final ic = isSelected
        ? Colors.white
        : (iconColor ?? palette.accent);

    final widget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isSelected
                ? null
                : Border.all(color: palette.border.withOpacity(0.5), width: 1),
          ),
          child: Center(
            child: Icon(icon, size: size * 0.44, color: ic),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? palette.primaryText : palette.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: widget,
      );
    }

    return widget;
  }
}
