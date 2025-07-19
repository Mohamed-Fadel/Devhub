import 'package:devhub/core/network/api_client.dart';
import 'package:devhub/core/network/error/exceptions.dart';
import 'package:devhub/features/profile/data/api/profile_endpoints.dart';
import 'package:devhub/features/profile/data/models/profile_model.dart';
import 'package:devhub/features/profile/data/models/skill_model.dart';
import 'package:devhub/features/profile/domain/entities/skill.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<ProfileModel> updateProfile(ProfileModel profile);
  Future<List<SkillModel>> updateSkills(String userId, List<Skill> skills);
  Future<String> uploadAvatar(String userId, String imagePath);
}

@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final HttpClient _apiClient;

  ProfileRemoteDataSourceImpl(@Named('hostHttpClient') this._apiClient);

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await _apiClient.get(
        ProfileEndpoints.profileById(userId),
      );

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw ServerException(message:'Failed to load profile');
      }
    } on DioException catch (e) {
      throw ServerException(message:
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await _apiClient.put(
        ProfileEndpoints.profileById(profile.id),
        data: profile.toJson(),
      );

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw ServerException(message:'Failed to update profile');
      }
    } on DioException catch (e) {
      throw ServerException(message:
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<List<SkillModel>> updateSkills(
      String userId,
      List<Skill> skills,
      ) async {
    try {
      final response = await _apiClient.put(
        ProfileEndpoints.updateSkills(userId),
        data: {
          'skills': skills.map((s) => SkillModel.fromEntity(s).toJson()).toList(),
        },
      );

      if (response.statusCode == 200) {
        return (response.data['skills'] as List)
            .map((s) => SkillModel.fromJson(s))
            .toList();
      } else {
        throw ServerException(message:'Failed to update skills');
      }
    } on DioException catch (e) {
      throw ServerException(message:
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<String> uploadAvatar(String userId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imagePath),
      });

      final response = await _apiClient.post(
        ProfileEndpoints.uploadAvatar(userId),
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['avatarUrl'];
      } else {
        throw ServerException(message: 'Failed to upload avatar');
      }
    } on DioException catch (e) {
      throw ServerException(message:
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }
}
