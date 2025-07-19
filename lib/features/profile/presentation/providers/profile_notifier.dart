import 'package:devhub/core/domain/vo/result.dart';
import 'package:devhub/core/network/error/exceptions.dart';
import 'package:devhub/core/services/time_provider.dart';
import 'package:devhub/features/profile/domain/entities/achievement.dart';
import 'package:devhub/features/profile/domain/entities/github_stats.dart';
import 'package:devhub/features/profile/domain/entities/profile.dart';
import 'package:devhub/features/profile/domain/entities/skill.dart';
import 'package:devhub/features/profile/domain/usecases/fetch_github_stats_use_case.dart';
import 'package:devhub/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:devhub/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:devhub/features/profile/domain/usecases/update_skills_use_case.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

enum ProfileStatus { initial, loading, loaded, error }

@injectable
class ProfileNotifier extends ChangeNotifier {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdateSkillsUseCase _updateSkillsUseCase;
  final FetchGithubStatsUseCase _fetchGithubStatsUseCase;
  final TimeProvider _timeProvider;

  ProfileNotifier(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._updateSkillsUseCase,
    this._fetchGithubStatsUseCase,
    this._timeProvider,
  );

  Profile? _profile;
  ProfileStatus _status = ProfileStatus.initial;
  String? _errorMessage;
  bool _isUpdating = false;
  bool _isFetchingGithubStats = false;

  // Getters
  Profile? get profile => _profile;

  ProfileStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isUpdating => _isUpdating;

  bool get isFetchingGithubStats => _isFetchingGithubStats;

  bool get hasProfile => _profile != null;

  // Computed getters
  List<Skill> get skills => _profile?.skills ?? [];

  List<Achievement> get achievements => _profile?.achievements ?? [];

  GithubStats? get githubStats => _profile?.githubStats;

  String get displayName => _profile?.name ?? 'Unknown';

  String get displayRole => _profile?.role ?? 'Developer';

  String? get avatarUrl => _profile?.avatarUrl;

  // Load profile
  Future<void> loadProfile(String userId) async {
    _status = ProfileStatus.loading;
    notifyListeners();

    final result = await _getProfileUseCase(userId);

    result.fold(
      onSuccess: (profile) {
        _profile = profile;
        _status = ProfileStatus.loaded;
        _errorMessage = null;

        // Fetch GitHub stats if username is available
        if (profile.githubUsername != null) {
          _fetchGithubStats(profile.githubUsername!);
        }
      },
      onFailure: (exception) {
        _status = ProfileStatus.error;
        _errorMessage = _getErrorMessage(exception);
      },
    );

    notifyListeners();
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? role,
    String? location,
    String? githubUsername,
  }) async {
    if (_profile == null) return;

    _isUpdating = true;
    notifyListeners();

    final updatedProfile = _profile!.copyWith(
      name: name ?? _profile!.name,
      bio: bio ?? _profile!.bio,
      role: role ?? _profile!.role,
      location: location ?? _profile!.location,
      githubUsername: githubUsername ?? _profile!.githubUsername,
      lastUpdated: _timeProvider.now(),
    );

    final result = await _updateProfileUseCase(
      UpdateProfileParams(profile: updatedProfile),
    );

    result.fold(
      onSuccess: (profile) {
        _profile = profile;
        _errorMessage = null;

        // Fetch GitHub stats if username changed
        if (githubUsername != null &&
            githubUsername != _profile!.githubUsername) {
          _fetchGithubStats(githubUsername);
        }
      },
      onFailure: (exception) {
        _errorMessage = _getErrorMessage(exception);
      },
    );

    _isUpdating = false;
    notifyListeners();
  }

  // Pick and upload avatar
  Future<void> pickAndUploadAvatar(String? imagePath) async {
    _isUpdating = true;
    notifyListeners();

    // In a real app, you would upload to a storage service
    // For now, we'll just update the local path
    if(imagePath!=null) {
      final updatedProfile = _profile!.copyWith(
        // avatarUrl: imagePath, // should be replaced with actual avatar URL after upload
        lastUpdated: _timeProvider.now(),
      );

      final result = await _updateProfileUseCase(
        UpdateProfileParams(profile: updatedProfile),
      );

      result.fold(
        onSuccess: (profile) {
          _profile = profile;
          _errorMessage = null;
        },
        onFailure: (failure) => _errorMessage = failure.toString(),
      );
    } else {
      _errorMessage = 'No image selected';
    }

    _isUpdating = false;
    notifyListeners();
  }

  // Update skills
  Future<void> updateSkills(List<Skill> skills) async {
    if (_profile == null) return;

    _isUpdating = true;
    notifyListeners();

    final result = await _updateSkillsUseCase(
      UpdateSkillsParams(userId: _profile!.id, skills: skills),
    );

    result.fold(
      onSuccess: (updatedSkills) {
        _profile = _profile!.copyWith(skills: updatedSkills);
        _errorMessage = null;
      },
      onFailure: (exception) {
        _errorMessage = _getErrorMessage(exception);
      },
    );

    _isUpdating = false;
    notifyListeners();
  }

  // Add skill
  void addSkill(Skill skill) {
    if (_profile == null) return;

    final updatedSkills = [..._profile!.skills, skill];
    updateSkills(updatedSkills);
  }

  // Remove skill
  void removeSkill(String skillId) {
    if (_profile == null) return;

    final updatedSkills =
        _profile!.skills.where((skill) => skill.id != skillId).toList();
    updateSkills(updatedSkills);
  }

  // Update skill level
  void updateSkillLevel(String skillId, SkillLevel newLevel) {
    if (_profile == null) return;

    final updatedSkills =
        _profile!.skills.map((skill) {
          if (skill.id == skillId) {
            return skill.copyWith(level: newLevel);
          }
          return skill;
        }).toList();

    updateSkills(updatedSkills);
  }

  // Fetch GitHub stats
  Future<void> _fetchGithubStats(String username) async {
    _isFetchingGithubStats = true;
    notifyListeners();

    final result = await _fetchGithubStatsUseCase(username);

    result.fold(
      onSuccess: (stats) {
        _profile = _profile!.copyWith(githubStats: stats);
      },
      onFailure: (exception) {
        debugPrint(
          'Failed to fetch GitHub stats: ${_getErrorMessage(exception)}',
        );
      },
    );

    _isFetchingGithubStats = false;
    notifyListeners();
  }

  // Refresh GitHub stats
  Future<void> refreshGithubStats() async {
    if (_profile?.githubUsername != null) {
      await _fetchGithubStats(_profile!.githubUsername!);
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _profile = null;
    _status = ProfileStatus.initial;
    _errorMessage = null;
    _isUpdating = false;
    _isFetchingGithubStats = false;
    notifyListeners();
  }

  // Helper method to get error message from exception
  String _getErrorMessage(Exception exception) {
    if (exception is ServerException) {
      return exception.message;
    } else if (exception is CacheException) {
      return exception.message;
    } else if (exception is NetworkException) {
      return exception.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
}
