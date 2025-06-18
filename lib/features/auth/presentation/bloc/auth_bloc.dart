import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_bloc.freezed.dart';

part 'auth_event.dart';

part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final AuthRepository _authRepository;

  AuthBloc(this._signInUseCase, this._signUpUseCase, this._authRepository)
    : super(const AuthState.initial()) {
    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(AuthEvent.userChanged(user));
      } else {
        add(const AuthEvent.signedOut());
      }
    });

    on<AuthEvent>((event, emit) async {
      switch (event) {
        case _SignInRequested(:final email, :final password):
          await _onSignInRequested(emit, email, password);
        case _SignUpRequested(:final email, :final password, :final name):
          await _onSignUpRequested(emit, email, password, name);
        case _GoogleSignInRequested():
          await _onGoogleSignInRequested(emit);
        case _GithubSignInRequested():
          await _onGithubSignInRequested(emit);
        case _SignOutRequested():
          await _onSignOutRequested(emit);
        case _ResetPasswordRequested(:final email):
          await _onResetPasswordRequested(emit, email);
        case _UserChanged(:final user):
          _onUserChanged(emit, user);
        case _SignedOut():
          _onSignedOut(emit);
        case _GetCurrentUser():
          await _onGetCurrentUser(emit);
        default:
          throw UnimplementedError('Event not implemented: $event');
      }
    });
  }

  Future<void> _onSignInRequested(
    Emitter<AuthState> emit,
    String email,
    String password,
  ) async {
    emit(const AuthState.loading());

    final result = await _signInUseCase(
      SignInParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    Emitter<AuthState> emit,
    String email,
    String password,
    String name,
  ) async {
    emit(const AuthState.loading());

    final result = await _signUpUseCase(
      SignUpParams(email: email, password: password, name: name),
    );

    result.fold(
      (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onGoogleSignInRequested(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onGithubSignInRequested(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signInWithGitHub();

    result.fold(
      (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  Future<void> _onResetPasswordRequested(
    Emitter<AuthState> emit,
    String email,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.resetPassword(email: email);

    result.fold(
      (failure) => emit(AuthState.error(_mapFailureToMessage(failure))),
      (_) => emit(const AuthState.passwordResetSent()),
    );
  }

  void _onUserChanged(Emitter<AuthState> emit, User user) {
    emit(AuthState.authenticated(user));
  }

  void _onSignedOut(Emitter<AuthState> emit) {
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onGetCurrentUser(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final result = await _authRepository.getCurrentUser();

    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}
