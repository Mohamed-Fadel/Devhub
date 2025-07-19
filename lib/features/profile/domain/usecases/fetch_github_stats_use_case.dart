import 'package:devhub/core/domain/usecases/usecase.dart';
import 'package:devhub/core/domain/vo/result.dart';
import 'package:injectable/injectable.dart';
import '../entities/github_stats.dart';
import '../repositories/profile_repository.dart';

@injectable
class FetchGithubStatsUseCase implements ResultUseCase<GithubStats, String> {
  final ProfileRepository repository;

  FetchGithubStatsUseCase(this.repository);

  @override
  Future<Result<GithubStats>> call(String username) {
    return repository.fetchGithubStats(username);
  }
}