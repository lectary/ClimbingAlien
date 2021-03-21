class InternetException implements Exception {
  String _message;

  InternetException(this._message);

  @override
  String toString() {
    return 'InternetException{_message: $_message}';
  }
}
