import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_constants.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? animationAsset;
  final IconData? icon;
  final Widget? action;
  final double? iconSize;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.animationAsset,
    this.icon,
    this.action,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (animationAsset != null)
              Lottie.asset(
                animationAsset!,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Icon(
                icon,
                size: iconSize ?? 80,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),

            const SizedBox(height: AppConstants.spaceLG),

            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: AppConstants.spaceSM),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (action != null) ...[
              const SizedBox(height: AppConstants.spaceLG),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}