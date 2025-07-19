import 'package:devhub/core/domain/usecases/usecase.dart';
import 'package:devhub/core/domain/vo/result.dart';
import 'package:injectable/injectable.dart';
import '../entities/skill.dart';
import '../repositories/profile_repository.dart';

@injectable
class UpdateSkillsUseCase implements ResultUseCase<List<Skill>, UpdateSkillsParams> {
  final ProfileRepository repository;

  UpdateSkillsUseCase(this.repository);

  @override
  Future<Result<List<Skill>>> call(UpdateSkillsParams params) {
    return repository.updateSkills(params.userId, params.skills);
  }
}

class UpdateSkillsParams {
  final String userId;
  final List<Skill> skills;

  UpdateSkillsParams({required this.userId, required this.skills});
}
