part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.signInRequested({
    required String email,
    required String password,
  }) = _SignInRequested;

  const factory AuthEvent.signUpRequested({
    required String email,
    required String password,
    required String name,
  }) = _SignUpRequested;

  const factory AuthEvent.googleSignInRequested() = _GoogleSignInRequested;

  const factory AuthEvent.githubSignInRequested() = _GithubSignInRequested;

  const factory AuthEvent.signOutRequested() = _SignOutRequested;

  const factory AuthEvent.resetPasswordRequested({
    required String email,
  }) = _ResetPasswordRequested;

  const factory AuthEvent.userChanged(User user) = _UserChanged;

  const factory AuthEvent.signedOut() = _SignedOut;

  const factory AuthEvent.getCurrentUser() = _GetCurrentUser;

  const factory AuthEvent.resendVerificationEmail({
    required String email,
  }) = _ResendVerificationEmail;
}
