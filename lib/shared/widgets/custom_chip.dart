import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final IconData? icon;
  final bool isSmall;

  const CustomChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.onPressed,
    this.onDeleted,
    this.isSelected = false,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (onPressed != null) {
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onPressed?.call(),
        backgroundColor: backgroundColor,
        selectedColor: backgroundColor ?? theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? (foregroundColor ?? Colors.white)
              : (foregroundColor ?? theme.colorScheme.onSurface),
          fontSize: isSmall ? 12 : null,
        ),
        avatar: icon != null ? Icon(icon, size: isSmall ? 16 : 18) : null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: isSmall ? VisualDensity.compact : null,
      );
    } else {
      return Chip(
        label: Text(label),
        backgroundColor: backgroundColor,
        labelStyle: TextStyle(
          color: foregroundColor ?? theme.colorScheme.onSurface,
          fontSize: isSmall ? 12 : null,
        ),
        avatar: icon != null ? Icon(icon, size: isSmall ? 16 : 18) : null,
        onDeleted: onDeleted,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: isSmall ? VisualDensity.compact : null,
      );
    }
  }
}