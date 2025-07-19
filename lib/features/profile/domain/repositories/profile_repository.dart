import '../../../../core/domain/vo/result.dart';
import '../entities/profile.dart';
import '../entities/skill.dart';
import '../entities/github_stats.dart';

abstract class ProfileRepository {
  Future<Result<Profile>> getProfile(String userId);
  Future<Result<Profile>> updateProfile(Profile profile);
  Future<Result<List<Skill>>> updateSkills(String userId, List<Skill> skills);
  Future<Result<GithubStats>> fetchGithubStats(String username);
  Future<Result<String>> uploadAvatar(String userId, String imagePath);
  Future<Result<Profile>> getCachedProfile();
  Future<Result<void>> cacheProfile(Profile profile);
}