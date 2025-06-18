import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
sealed class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? avatar,
    String? bio,
    List<String>? skills,
    String? githubUsername,
    String? linkedinUrl,
    String? websiteUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;
}
