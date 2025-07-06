import 'package:freezed_annotation/freezed_annotation.dart';

part 'developer_metric.freezed.dart';

enum MetricType {
  commits,
  pullRequests,
  issues,
  codeReviews,
  contributions,
}

@freezed
sealed class DeveloperMetric with _$DeveloperMetric {
  const factory DeveloperMetric({
    required MetricType type,
    required String label,
    required double value,
    required double previousValue,
    required String unit,
    required List<ChartPoint> chartData,
  }) = _DeveloperMetric;
}

@freezed
sealed class ChartPoint with _$ChartPoint {
  const factory ChartPoint({
    required DateTime date,
    required double value,
  }) = _ChartPoint;
}
