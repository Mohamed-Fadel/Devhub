import 'package:devhub/features/dashboard/data/models/activity_item_model.dart';
import 'package:devhub/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:devhub/features/dashboard/data/models/developer_metric_model.dart';
import 'package:hive/hive.dart';

void registerHiveAdapters() {
  // Register Hive adapters for all entities used in the dashboard feature models..
  Hive.registerAdapter(DashboardStatsModelAdapter());
  Hive.registerAdapter(DeveloperMetricModelAdapter());
  Hive.registerAdapter(MetricTypeAdapter());
  Hive.registerAdapter(ChartPointModelAdapter());
  Hive.registerAdapter(ActivityItemModelAdapter());
  Hive.registerAdapter(ActivityTypeAdapter());
}
