import 'dart:async';

import 'options.dart';

/// Helper class that contains the address options and indicates whether
/// opening a socket to it succeeded.
class NetworkCheckResult {
  final NetworkCheckOptions options;

  late final bool measureSuccessfully;

  late final int delayInMilliseconds;

  late final Object? error;

  NetworkCheckResult({required this.options});

  Future<R?> measure<R>(FutureOr<R> Function() computation) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await computation();
      measureSuccessfully = true;
      error = null;
      return result;
    } catch (err) {
      measureSuccessfully = false;
      error = err;
    } finally {
      stopwatch.stop();
      delayInMilliseconds = stopwatch.elapsedMilliseconds;
    }
    return null;
  }

  @override
  String toString() {
    return 'NetworkCheckResult{options: $options, measureSuccessfully: $measureSuccessfully, delayInMilliseconds: $delayInMilliseconds, error: $error}';
  }
}
