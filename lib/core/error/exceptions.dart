class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    required this.message,
  });
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    required this.message,
  });
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  const ValidationException({
    required this.message,
    this.errors,
  });
}

class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException({
    required this.message,
  });
}

class AuthorizationException implements Exception {
  final String message;

  const AuthorizationException({
    required this.message,
  });
}