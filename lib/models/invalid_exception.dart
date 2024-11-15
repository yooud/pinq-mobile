class InvalidSessionTokenException implements Exception {
  final String message;
  InvalidSessionTokenException(this.message);

  @override
  String toString() {
    return 'InvalidSessionTokenException: $message';
  }
}
