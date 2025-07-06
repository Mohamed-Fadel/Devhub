import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devhub/core/constants/app_constants.dart';
import 'package:devhub/features/dashboard/domain/entities/activity_item.dart';
import '../providers/dashboard_providers.dart';

class ActivityFeedWidget extends ConsumerWidget {
  const ActivityFeedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activityState = ref.watch(activityFeedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity page
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceMD),

        if (activityState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (activityState.error != null)
          Center(
            child: Text(
              activityState.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          )
        else if (activityState.activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLG),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    Text(
                      'No recent activity',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activityState.activities.take(5).length,
              separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceSM),
              itemBuilder: (context, index) {
                final activity = activityState.activities[index];
                return _ActivityItem(activity: activity);
              },
            ),
      ],
    );
  }
}

class _ActivityItem extends ConsumerWidget {
  final ActivityItem activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        if (!activity.isRead) {
          ref.read(activityFeedProvider.notifier).markAsRead(activity.id);
        }
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        decoration: BoxDecoration(
          color: activity.isRead
              ? theme.colorScheme.surface
              : theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getActivityColor(activity.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActivityIcon(activity.type),
                color: _getActivityColor(activity.type),
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(activity.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.projectCreated:
        return Icons.add_box;
      case ActivityType.projectUpdated:
        return Icons.update;
      case ActivityType.newFollower:
        return Icons.person_add;
      case ActivityType.githubActivity:
        return Icons.code;
      case ActivityType.achievement:
        return Icons.emoji_events;
      case ActivityType.collaboration:
        return Icons.handshake;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.projectCreated:
        return Colors.blue;
      case ActivityType.projectUpdated:
        return Colors.green;
      case ActivityType.newFollower:
        return Colors.purple;
      case ActivityType.githubActivity:
        return Colors.orange;
      case ActivityType.achievement:
        return Colors.amber;
      case ActivityType.collaboration:
        return Colors.teal;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
