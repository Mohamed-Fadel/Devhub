import 'package:devhub/core/domain/vo/result.dart';
import 'package:devhub/core/network/exceptions.dart';
import 'package:devhub/core/network/network_info.dart';
import 'package:devhub/features/profile/data/data_sources/github_api_data_source.dart';
import 'package:devhub/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:devhub/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:devhub/features/profile/data/models/profile_model.dart';
import 'package:devhub/features/profile/data/models/skill_model.dart';
import 'package:devhub/features/profile/data/models/github_stats_model.dart';
import 'package:devhub/features/profile/domain/entities/github_stats.dart';
import 'package:devhub/features/profile/domain/entities/profile.dart';
import 'package:devhub/features/profile/domain/entities/skill.dart';
import 'package:devhub/features/profile/domain/repositories/profile_repository.dart';
import 'package:injectable/injectable.dart';


@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final GithubApiDataSource githubApiDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.githubApiDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<Profile>> getProfile(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getProfile(userId);
        await localDataSource.cacheProfile(remoteProfile);
        return Result.success(remoteProfile.toEntity());
      } on Exception catch (e) {
        return Result.failure(e);
      }
    } else {
      try {
        final localProfile = await localDataSource.getCachedProfile();
        return Result.success(localProfile.toEntity());
      } on Exception catch (e) {
        return Result.failure(e);
      }
    }
  }

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async {
    if (await networkInfo.isConnected) {
      try {
        final profileModel = ProfileModel.fromEntity(profile);
        final updatedProfile = await remoteDataSource.updateProfile(profileModel);
        await localDataSource.cacheProfile(updatedProfile);
        return Result.success(updatedProfile.toEntity());
      } on Exception catch (e) {
        return Result.failure(e);
      }
    } else {
      return Result.failure(NetworkException(message:'No internet connection'));
    }
  }

  @override
  Future<Result<List<Skill>>> updateSkills(
      String userId,
      List<Skill> skills,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedSkills = await remoteDataSource.updateSkills(userId, skills);
        // Update cached profile with new skills
        try {
          final cachedProfile = await localDataSource.getCachedProfile();
          final updatedProfile = cachedProfile.copyWith(skills: updatedSkills);
          await localDataSource.cacheProfile(updatedProfile);
        } catch (_) {
          // Ignore cache errors
        }
        return Result.success(updatedSkills.map((s) => s.toEntity()).toList());
      } on Exception catch (e) {
        return Result.failure(e);
      }
    } else {
      return Result.failure(NetworkException(message:'No internet connection'));
    }
  }

  @override
  Future<Result<GithubStats>> fetchGithubStats(String username) async {
    if (await networkInfo.isConnected) {
      try {
        final stats = await githubApiDataSource.fetchGithubStats(username);
        return Result.success(stats.toEntity());
      } on Exception catch (e) {
        return Result.failure(e);
      }
    } else {
      return Result.failure(NetworkException(message:'No internet connection'));
    }
  }

  @override
  Future<Result<String>> uploadAvatar(
      String userId,
      String imagePath,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final avatarUrl = await remoteDataSource.uploadAvatar(userId, imagePath);
        return Result.success(avatarUrl);
      } on Exception catch (e) {
        return Result.failure(e);
      }
    } else {
      return Result.failure(NetworkException(message:'No internet connection'));
    }
  }

  @override
  Future<Result<Profile>> getCachedProfile() async {
    try {
      final profile = await localDataSource.getCachedProfile();
      return Result.success(profile.toEntity());
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> cacheProfile(Profile profile) async {
    try {
      final profileModel = ProfileModel.fromEntity(profile);
      await localDataSource.cacheProfile(profileModel);
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }
}
