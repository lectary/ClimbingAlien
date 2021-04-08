class InternetException implements Exception {
  String _message;

  InternetException(this._message);

  @override
  String toString() {
    return _message;
  }
}
