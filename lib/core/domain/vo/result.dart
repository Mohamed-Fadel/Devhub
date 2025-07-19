import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = _Success<T>;

  const factory Result.failure(Exception exception) = _Failure<T>;
}

/// Core transformation methods
extension ResultTransformX<T> on Result<T> {
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      _Success(:final data) => Result.success(transform(data)),
      _Failure(:final exception) => Result.failure(exception),
    };
  }

  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      _Success(:final data) => transform(data),
      _Failure(:final exception) => Result.failure(exception),
    };
  }
}

/// Pattern matching and folding methods
extension ResultMatchX<T> on Result<T> {
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Exception exception) onFailure,
  }) {
    return switch (this) {
      _Success(:final data) => onSuccess(data),
      _Failure(:final exception) => onFailure(exception),
    };
  }

  R when<R>({
    required R Function(T data) success,
    required R Function(Exception exception) failure,
  }) {
    return fold(onSuccess: success, onFailure: failure);
  }
}

/// Value extraction methods
extension ResultValueX<T> on Result<T> {
  T getOrElse(T defaultValue) {
    return switch (this) {
      _Success(:final data) => data,
      _Failure() => defaultValue,
    };
  }

  T? getOrNull() {
    return switch (this) {
      _Success(:final data) => data,
      _Failure() => null,
    };
  }

  Exception? get exception {
    return switch (this) {
      _Success() => null,
      _Failure(:final exception) => exception,
    };
  }
}

/// State checking and side effects
extension ResultStateX<T> on Result<T> {
  bool get isSuccess => this is _Success<T>;

  bool get isFailure => this is _Failure<T>;

  Result<T> onSuccess(void Function(T value) action) {
    if (this case _Success(:final data)) {
      action(data);
    }
    return this;
  }

  Result<T> onFailure(void Function(Exception exception) action) {
    if (this case _Failure(:final exception)) {
      action(exception);
    }
    return this;
  }
}
