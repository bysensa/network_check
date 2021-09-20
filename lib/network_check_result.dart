import 'dart:async';

import 'network_check_options.dart';

/// Helper class that contains the address options and indicates whether
/// opening a socket to it succeeded.
class NetworkCheckResult {
  final NetworkCheckOptions options;

  bool _measureSuccessfully;
  bool get isSuccess => _measureSuccessfully ?? false;

  int _delayInMilliseconds;
  Duration get delay => Duration(milliseconds: _delayInMilliseconds ?? 0);

  Object _error;
  Object get error => _error;

  NetworkCheckResult(
    this.options,
  );

  Future<void> measure(FutureOr Function() computation) async {
    var delayInMilliseconds = 0;
    var computeSuccessfully = false;
    final stopwatch = Stopwatch()..start();
    try {
      await computation();
      computeSuccessfully = true;
    } catch (err) {
      computeSuccessfully = false;
      _error = err;
    } finally {
      stopwatch.stop();
      delayInMilliseconds = stopwatch.elapsedMilliseconds;
    }
    _measureSuccessfully = computeSuccessfully;
    _delayInMilliseconds = delayInMilliseconds;
  }

  @override
  String toString() =>
      'NetworkCheckResult($options, $isSuccess, ${_delayInMilliseconds}ms, $error)';
}
