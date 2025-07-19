import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';

class AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsSection({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (achievements.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.emoji_events, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No achievements yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: achievements.take(4).map((achievement) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _AchievementBadge(achievement: achievement),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${achievement.title}\n${achievement.description}',
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              _getColorForType(achievement.type).withOpacity(0.8),
              _getColorForType(achievement.type),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _getColorForType(achievement.type).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            achievement.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  Color _getColorForType(AchievementType? type) {
    switch (type) {
      case AchievementType.contribution:
        return Colors.blue;
      case AchievementType.milestone:
        return Colors.purple;
      case AchievementType.certification:
        return Colors.orange;
      case AchievementType.special:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}