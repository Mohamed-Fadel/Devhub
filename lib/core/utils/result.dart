import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = _Success<T>;
  const factory Result.failure(String error) = _Failure<T>;
}

extension ResultX<T> on Result<T> {
  bool get isSuccess => this is _Success<T>;
  bool get isFailure => this is _Failure<T>;

  T? get data => switch (this) {
    _Success(data: final value) => value,
    _ => null,
  };

  String? get error => switch (this) {
    _Failure(error: final value) => value,
    _ => null,
  };

}
