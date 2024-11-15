class NullSessionTokenException implements Exception {
  final String message;
  NullSessionTokenException(this.message);

  @override
  String toString() {
    return 'NullSessionTokenException: $message';
  }
}