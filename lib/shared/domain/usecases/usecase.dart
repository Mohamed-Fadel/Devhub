import 'package:dartz/dartz.dart';
import 'package:devhub/core/domain/vo/result.dart';
import 'package:devhub/core/domain/vo/failures.dart';

@Deprecated('Use ResultUseCase instead')
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class ResultUseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
