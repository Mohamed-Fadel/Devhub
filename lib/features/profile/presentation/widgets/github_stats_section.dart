import 'package:flutter/material.dart';
import '../../domain/entities/github_stats.dart';

class GithubStatsSection extends StatelessWidget {
  final GithubStats? stats;
  final String username;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const GithubStatsSection({
    super.key,
    this.stats,
    required this.username,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GitHub Stats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  icon: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.refresh),
                  onPressed: isLoading ? null : onRefresh,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (stats == null && !isLoading)
            Center(
              child: Column(
                children: [
                  Icon(Icons.code, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'GitHub stats not available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else if (isLoading && stats == null)
            const Center(child: CircularProgressIndicator())
          else if (stats != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    value: stats!.repositories.toString(),
                    label: 'Repositories',
                    icon: Icons.folder_outlined,
                  ),
                  _StatItem(
                    value: _formatNumber(stats!.stars),
                    label: 'Stars',
                    icon: Icons.star_outline,
                  ),
                  _StatItem(
                    value: _formatNumber(stats!.followers),
                    label: 'Followers',
                    icon: Icons.people_outline,
                  ),
                ],
              ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}