
class AppException implements Exception {
  final String message;

 const AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException(super.message);
}

class AuthException extends AppException {

  AuthException(super.message);
}
