class ServerResponseException implements Exception {
  String _message;

  ServerResponseException(this._message);

  @override
  String toString() {
    return 'ServerResponseException{_message: $_message}';
  }
}
