import 'package:devhub/core/domain/usecases/usecase.dart';
import 'package:devhub/core/domain/vo/result.dart';
import 'package:injectable/injectable.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

@injectable
class GetProfileUseCase implements ResultUseCase<Profile, String> {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Result<Profile>> call(String userId) async {
    // First try to get cached profile for faster loading
    final cachedResult = await repository.getCachedProfile();

    // Fetch fresh data from remote
    final remoteResult = await repository.getProfile(userId);

    // Cache the fresh data if successful
    remoteResult.onSuccess((profile) => repository.cacheProfile(profile));

    // Return remote data if available, otherwise cached data
    return remoteResult.isSuccess ? remoteResult : cachedResult;
  }
}