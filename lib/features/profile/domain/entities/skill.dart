import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill.freezed.dart';

@freezed
sealed class Skill with _$Skill {
  const factory Skill({
    required String id,
    required String name,
    required SkillLevel level,
    String? icon,
    int? yearsOfExperience,
  }) = _Skill;
}

enum SkillLevel { beginner, intermediate, advanced, expert }