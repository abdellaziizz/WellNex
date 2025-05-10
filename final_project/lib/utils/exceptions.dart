class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class FirebaseInitializationException implements Exception {
  final String message;
  FirebaseInitializationException(this.message);

  @override
  String toString() => 'FirebaseInitializationException: $message';
}

class FirestoreException implements Exception {
  final String message;
  FirestoreException(this.message);

  @override
  String toString() => 'FirestoreException: $message';
}

class FirebaseConnectionException implements Exception {
  final String message;
  FirebaseConnectionException(this.message);

  @override
  String toString() => 'FirebaseConnectionException: $message';
} 