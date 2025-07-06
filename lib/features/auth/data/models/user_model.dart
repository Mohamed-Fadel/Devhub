import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:devhub/features/auth/domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@Freezed(fromJson: true)
sealed class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    String? avatar,
    String? bio,
    List<String>? skills,
    @JsonKey(name: 'github_username') String? githubUsername,
    @JsonKey(name: 'linkedin_url') String? linkedinUrl,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      avatar: avatar,
      bio: bio,
      skills: skills,
      githubUsername: githubUsername,
      linkedinUrl: linkedinUrl,
      websiteUrl: websiteUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension UserX on User {
  UserModel toModel() {
    return UserModel(
      id: id,
      email: email,
      name: name,
      avatar: avatar,
      bio: bio,
      skills: skills,
      githubUsername: githubUsername,
      linkedinUrl: linkedinUrl,
      websiteUrl: websiteUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}


