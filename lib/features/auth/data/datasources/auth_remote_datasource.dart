import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> signInWithGoogle();

  Future<UserModel> signInWithGitHub();

  Future<void> signOut();

  Future<UserModel> getCurrentUser();

  Future<void> resetPassword({
    required String email,
  });

  Future<UserModel> updateProfile({
    required UserModel user,
  });
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/signin',
        data: {
          'email': email,
          'password': password,
        },
      );

      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/signup',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final response = await dioClient.post('/auth/google');
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGitHub() async {
    try {
      final response = await dioClient.post('/auth/github');
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await dioClient.post('/auth/signout');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.get('/auth/me');
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await dioClient.post(
        '/auth/reset-password',
        data: {'email': email},
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile({required UserModel user}) async {
    try {
      final response = await dioClient.put(
        '/auth/profile',
        data: user.toJson(),
      );
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
