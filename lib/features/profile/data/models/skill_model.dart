import 'package:devhub/features/profile/domain/entities/skill.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill_model.freezed.dart';

part 'skill_model.g.dart';

@freezed
sealed class SkillModel with _$SkillModel {
  const factory SkillModel({
    required String id,
    required String name,
    required SkillLevel level,
    String? icon,
    int? yearsOfExperience,
  }) = _SkillModel;

  factory SkillModel.fromJson(Map<String, dynamic> json) =>
      _$SkillModelFromJson(json);

  factory SkillModel.fromEntity(Skill skill) => SkillModel(
    id: skill.id,
    name: skill.name,
    level: skill.level,
    icon: skill.icon,
    yearsOfExperience: skill.yearsOfExperience,
  );
}

extension SkillModelX on SkillModel {
  Skill toEntity() => Skill(
    id: id,
    name: name,
    level: level,
    icon: icon,
    yearsOfExperience: yearsOfExperience,
  );
}
