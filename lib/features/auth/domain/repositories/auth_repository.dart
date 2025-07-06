import 'package:dartz/dartz.dart';

import 'package:devhub/core/network/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, User>> signInWithGitHub();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  Future<Either<Failure, User>> updateProfile({
    required User user,
  });

  Stream<User?> get authStateChanges;
}