import 'package:devhub/core/data/database/hive_config.dart';
import 'package:devhub/features/dashboard/domain/entities/activity_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'activity_item_model.freezed.dart';
part 'activity_item_model.g.dart';

@freezed
@HiveType(typeId: HiveTypeIds.activity)
sealed class ActivityItemModel with _$ActivityItemModel {
  const factory ActivityItemModel({
    @HiveField(0) required String id,
    @HiveField(1) required ActivityType type,
    @HiveField(2) required String title,
    @HiveField(3) required String description,
    @HiveField(4) required DateTime timestamp,
    @HiveField(5) Map<String, dynamic>? metadata,
    @HiveField(6) required bool isRead,
  }) = _ActivityItemModel;

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemModelFromJson(json);
}

extension ActivityItemModelX on ActivityItemModel {
  ActivityItem toEntity() => ActivityItem(
    id: id,
    type: type,
    title: title,
    description: description,
    timestamp: timestamp,
    metadata: metadata,
    isRead: isRead,
  );
}

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = HiveTypeIds.activityType;

  @override
  ActivityType read(BinaryReader reader) {
    final index = reader.readByte();
    return ActivityType.values.elementAtOrNull(index) ?? ActivityType.values.first;
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    writer.writeByte(ActivityType.values.indexOf(obj));
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ActivityTypeAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}