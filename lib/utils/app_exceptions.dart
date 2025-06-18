abstract class AppException implements Exception {
  final String? _message;
  final String? _prefix;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

/// Exception for general network-related errors (e.g., no internet connection).
class NetworkException extends AppException {
  NetworkException([String? message]) : super(message, "Network Error: ");
}

/// Exception specifically for GitHub API rate limit errors.
/// This happens when you exceed 60 unauthenticated requests per hour.
class RateLimitExceededException extends AppException {
  RateLimitExceededException([String? message])
    : super(message, "Rate Limit Exceeded: ");
}

/// Exception for bad requests (client-side errors, status codes 400-499).
class BadRequestException extends AppException {
  BadRequestException([String? message]) : super(message, "Invalid Request: ");
}

/// Exception for unauthorized access (status code 401).
class UnauthorizedException extends AppException {
  UnauthorizedException([String? message]) : super(message, "Unauthorized: ");
}

/// Exception for server-side errors (status codes 500-599).
class ServerException extends AppException {
  ServerException([String? message]) : super(message, "Server Error: ");
}

/// Exception for when data fetching fails for other reasons.
class FetchDataException extends AppException {
  FetchDataException([String? message])
    : super(message, "Data Fetching Error: ");
}

/// Exception for general, unhandled errors within the application logic.
class AppLogicException extends AppException {
  AppLogicException([String? message])
    : super(message, "Application Logic Error: ");
}

/// Exception for local storage-related errors (e.g., reading/writing issues).
class LocalStorageException extends AppException {
  LocalStorageException([String? message])
    : super(message, "Local Storage Error: ");
}
