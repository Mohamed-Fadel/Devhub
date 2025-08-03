import 'dart:convert';
import 'package:devhub/core/network/exceptions.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel> getCachedProfile();
  Future<void> cacheProfile(ProfileModel profile);
  Future<void> clearCache();
}

@Injectable(as: ProfileLocalDataSource)
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String profileBoxKey = 'profile_box';
  static const String profileKey = 'cached_profile';

  @override
  Future<ProfileModel> getCachedProfile() async {
    try {
      final box = await Hive.openBox(profileBoxKey);
      final jsonString = box.get(profileKey);

      if (jsonString != null) {
        return ProfileModel.fromJson(json.decode(jsonString));
      } else {
        throw CacheException(message: 'No cached profile found');
      }
    } catch (e) {
      throw CacheException(message: 'Failed to load cached profile');
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    try {
      final box = await Hive.openBox(profileBoxKey);
      await box.put(profileKey, json.encode(profile.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to cache profile');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox(profileBoxKey);
      await box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache');
    }
  }
}