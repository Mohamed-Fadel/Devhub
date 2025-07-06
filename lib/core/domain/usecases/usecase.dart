import 'package:dartz/dartz.dart';
import 'package:devhub/core/network/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
