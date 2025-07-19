import 'package:devhub/core/domain/usecases/usecase.dart';
import 'package:devhub/core/domain/vo/result.dart';
import 'package:injectable/injectable.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

@injectable
class UpdateProfileUseCase implements ResultUseCase<Profile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Result<Profile>> call(UpdateProfileParams params) async {
    final result = await repository.updateProfile(params.profile);

    // Cache updated profile
    result.onSuccess((profile) => repository.cacheProfile(profile));

    return result;
  }
}

class UpdateProfileParams {
  final Profile profile;

  UpdateProfileParams({required this.profile});
}
