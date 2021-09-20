class NetworkCheckCompleter {
  bool _completed = false;

  bool get isCompleted => _completed;
  bool get isNotCompleted => !isCompleted;

  void complete() {
    _completed = true;
  }
}
