import 'package:devhub/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:devhub/core/constants/app_constants.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stats_card.dart';
import '../widgets/activity_feed_widget.dart';
import '../widgets/developer_chart.dart';

@RoutePage()
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardStats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardRefreshProvider.future),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: DashboardHeader(
                onNotificationTap: () {
                  // Navigate to notifications
                },
              ),
            ),

            // Stats Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMD),
                child: dashboardStats.when(
                  data: (stats) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      _buildStatsGrid(stats),
                    ],
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ),



            // Developer Metrics Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMD),
                child: dashboardStats.maybeWhen(
                  data: (stats) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance Metrics',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      SizedBox(
                        height: 300,
                        child: DeveloperChart(metrics: stats.metrics),
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            ),

            // Activity Feed
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMD,
                ),
                child: ActivityFeedWidget(),
              ),
            ),

            // Bottom padding
            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppConstants.spaceLG),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppConstants.spaceMD,
      mainAxisSpacing: AppConstants.spaceMD,
      childAspectRatio: 1.5,
      children: [
        StatsCard(
          title: 'Projects',
          value: stats.totalProjects.toString(),
          icon: Icons.folder,
          color: Colors.blue,
          trend: stats.weeklyGrowth,
        ),
        StatsCard(
          title: 'Followers',
          value: _formatNumber(stats.totalFollowers),
          icon: Icons.people,
          color: Colors.green,
          trend: stats.weeklyGrowth,
        ),
        StatsCard(
          title: 'Stars',
          value: _formatNumber(stats.totalStars),
          icon: Icons.star,
          color: Colors.amber,
          trend: stats.weeklyGrowth,
        ),
        StatsCard(
          title: 'Commits',
          value: _formatNumber(stats.totalCommits),
          icon: Icons.code,
          color: Colors.purple,
          trend: stats.weeklyGrowth,
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
