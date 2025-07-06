import 'package:devhub/core/data/database/hive/hive_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:devhub/features/dashboard/domain/entities/developer_metric.dart';
import 'package:hive/hive.dart';

part 'developer_metric_model.freezed.dart';
part 'developer_metric_model.g.dart';

@freezed
@HiveType(typeId: HiveTypeIds.developerMetric)
sealed class DeveloperMetricModel with _$DeveloperMetricModel {
  const factory DeveloperMetricModel({
    @HiveField(0) required MetricType type,
    @HiveField(1) required String label,
    @HiveField(2) required double value,
    @HiveField(3) required double previousValue,
    @HiveField(4) required String unit,
    @HiveField(5) required List<ChartPointModel> chartData,
  }) = _DeveloperMetricModel;

  factory DeveloperMetricModel.fromJson(Map<String, dynamic> json) =>
      _$DeveloperMetricModelFromJson(json);
}

@freezed
@HiveType(typeId: HiveTypeIds.chartPoint)
sealed class ChartPointModel with _$ChartPointModel {
  const factory ChartPointModel({
    @HiveField(0) required DateTime date,
    @HiveField(1) required double value,
  }) = _ChartPointModel;

  factory ChartPointModel.fromJson(Map<String, dynamic> json) =>
      _$ChartPointModelFromJson(json);
}

extension DeveloperMetricModelX on DeveloperMetricModel {
  DeveloperMetric toEntity() => DeveloperMetric(
    type: type,
    label: label,
    value: value,
    previousValue: previousValue,
    unit: unit,
    chartData: chartData.map((p) => p.toEntity()).toList(),
  );
}

extension ChartPointModelX on ChartPointModel {
  ChartPoint toEntity() => ChartPoint(
    date: date,
    value: value,
  );
}

class MetricTypeAdapter extends TypeAdapter<MetricType> {
  @override
  final int typeId = HiveTypeIds.metricType;

  @override
  MetricType read(BinaryReader reader) {
    final index = reader.readByte();
    return MetricType.values.elementAtOrNull(index) ?? MetricType.values.first;
  }

  @override
  void write(BinaryWriter writer, MetricType obj) {
    writer.writeByte(MetricType.values.indexOf(obj));
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}