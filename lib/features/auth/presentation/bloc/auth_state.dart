part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;

  const factory AuthState.loading() = Loading;

  const factory AuthState.authenticated(User user) = Authenticated;

  const factory AuthState.unauthenticated() = Unauthenticated;

  const factory AuthState.error(String message) = Error;

  const factory AuthState.passwordResetSent({String? email}) = PasswordResetSent;

  const factory AuthState.biometricAuthenticationRequired() = BiometricAuthenticationRequired;

  const factory AuthState.tokenExpired() = TokenExpired;

  const factory AuthState.emailVerificationRequired({
    required String email,
  }) = EmailVerificationRequired;

  const factory AuthState.emailVerificationSent({
    required String email,
  }) = EmailVerificationSent;

  const factory AuthState.socialSignInInProgress({
    required String provider, // 'google', 'github', etc.
  }) = SocialSignInInProgress;
}