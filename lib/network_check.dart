import 'dart:async';
import 'dart:io';

import 'package:data_connection_checker/buffer.dart';
import 'package:data_connection_checker/network_check_completer.dart';
import 'package:data_connection_checker/network_quality.dart';
import 'package:data_connection_checker/network_stats.dart';
import 'package:meta/meta.dart';

import 'constants.dart';
import 'network_check_options.dart';
import 'network_check_result.dart';
import 'network_status.dart';

/// Ping a single address. See [NetworkCheckOptions] for
/// info on the accepted argument.
Future<NetworkCheckResult> isHostReachable(NetworkCheckOptions options, {Duration timeout}) async {
  Socket sock;
  final result = NetworkCheckResult(options);
  if (options.secured) {
    await result.measure(() async {
      sock = await Socket.connect(
        options.address,
        options.port,
        timeout: timeout,
      );
    });
  } else {
    await result.measure(() async {
      sock = await SecureSocket.connect(
        options.address,
        options.port,
        timeout: timeout,
      );
    });
  }
  sock?.destroy();
  return result;
}

Future<Iterable<NetworkCheckResult>> isHostsReachable(
  Iterable<NetworkCheckOptions> options, {
  Duration timeout,
}) async {
  return await Future.wait(
    [for (final option in options) isHostReachable(option)],
    eagerError: false,
  );
}

/// This is a singleton that can be accessed like a regular constructor
/// i.e. DataConnectionChecker() always returns the same instance.
class NetworkCheck {
  static NetworkCheck _instance;

  /// A list of internet addresses (with port and timeout) to ping.
  ///
  /// These should be globally available destinations.
  /// Default is [DEFAULT_ADDRESSES].
  ///
  /// When [hasConnection] or [connectionStatus] is called,
  /// this utility class tries to ping every address in this list.
  ///
  /// The provided addresses should be good enough to test for data connection
  /// but you can, of course, supply your own.
  ///
  /// See [NetworkCheckOptions] for more info.
  final Set<NetworkCheckOptions> checkOptions;

  /// The interval between periodic checks. Periodic checks are
  /// only made if there's an attached listener to [onStatusChange].
  /// If that's the case [onStatusChange] emits an update only if
  /// there's change from the previous status.
  ///
  /// Defaults to [DEFAULT_INTERVAL] (10 seconds).
  final Duration checkInterval;

  final Duration minimumQualityDelay;

  final Set<Duration> qualityDelays;

  final Duration timeout;

  final _checkCompleters = <NetworkCheckCompleter>[];

  final Buffer _networkStatsBuffer;

  NetworkCheck._({
    @required this.checkOptions,
    @required this.checkInterval,
    @required this.minimumQualityDelay,
    @required this.qualityDelays,
    @required this.timeout,
    @required Buffer<NetworkStats> networkStatsBuffer,
  }) : _networkStatsBuffer = networkStatsBuffer;

  factory NetworkCheck({
    Duration checkInterval,
    Duration minimumQualityDelay,
    Set<NetworkCheckOptions> checkOptions,
    int bufferCapacity,
  }) {
    final currentCheckOptions = checkOptions ?? defaultCheckOptions;
    final currentMinimumQualityDelay = minimumQualityDelay ?? defaultMinimumQualityDelay;
    final currentBufferCapacity = bufferCapacity ?? defaultBufferCapacity;

    assert(currentCheckOptions.isNotEmpty, 'checkOptions is empty');
    assert(currentMinimumQualityDelay > Duration.zero, 'minimumQualityDelay less or equals zero');

    final qualityDelays = NetworkQuality.values
        .map((e) => currentMinimumQualityDelay.inMilliseconds << e.index)
        .map((e) => Duration(milliseconds: e))
        .toSet();
    final timeout = qualityDelays.reduce((current, next) => current > next ? current : next);
    final currentCheckInterval = checkInterval ?? timeout;

    final newInstance = NetworkCheck._(
      checkInterval: currentCheckInterval,
      checkOptions: currentCheckOptions,
      minimumQualityDelay: currentMinimumQualityDelay,
      qualityDelays: qualityDelays,
      timeout: timeout,
      networkStatsBuffer: Buffer(capacity: currentBufferCapacity),
    );

    if (_instance == null) {
      return _instance ??= newInstance;
    }
    if (_instance == newInstance) {
      return _instance;
    }
    _instance.dispose();
    _instance = null;
    return _instance ??= newInstance;
  }

  Stream<NetworkStats> checkNetwork(NetworkCheckCompleter checkCompleter) async* {
    assert(checkCompleter != null, 'checkCompleter is null');
    if (checkCompleter == null) {
      return;
    }
    _checkCompleters.add(checkCompleter);
    while (checkCompleter.isNotCompleted) {
      await Future.wait([_checkNetwork(), Future.delayed(checkInterval)]);
      if (_networkStatsBuffer.isNotEmpty) {
        yield _networkStatsBuffer.last;
      }
      print('network checked');
    }
    return;
  }

  Future<NetworkStats> _checkNetwork() async {
    final results = await isHostsReachable(checkOptions, timeout: timeout);
    final successfulChecks = results.where((e) => e.isSuccess);
    final isConnected = successfulChecks.isNotEmpty;
    final minDelay = !isConnected
        ? timeout
        : successfulChecks
            .map((e) => e.delay)
            .reduce((current, next) => next < current ? next : current);
    final maxDelay = !isConnected
        ? timeout
        : successfulChecks
            .map((e) => e.delay)
            .reduce((current, next) => next > current ? next : current);
    final minQuality = NetworkQuality.values.firstWhere(
      (e) => minDelay.inMilliseconds < (minimumQualityDelay.inMilliseconds << e.index),
      orElse: () => NetworkQuality.wtf,
    );
    final maxQuality = NetworkQuality.values.firstWhere(
      (e) => maxDelay.inMilliseconds < (minimumQualityDelay.inMilliseconds << e.index),
      orElse: () => NetworkQuality.wtf,
    );
    final networkStats = NetworkStats(
      status: isConnected ? NetworkStatus.connected : NetworkStatus.disconnected,
      minDelay: minDelay,
      maxDelay: maxDelay,
      minQuality: minQuality,
      maxQuality: maxQuality,
    );
    _networkStatsBuffer.add(networkStats);
    return networkStats;
  }

  void dispose() {
    _checkCompleters.forEach((e) => e.complete());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkCheck &&
          runtimeType == other.runtimeType &&
          checkOptions == other.checkOptions &&
          checkInterval == other.checkInterval &&
          minimumQualityDelay == other.minimumQualityDelay &&
          qualityDelays == other.qualityDelays &&
          timeout == other.timeout;

  @override
  int get hashCode =>
      checkOptions.hashCode ^
      checkInterval.hashCode ^
      minimumQualityDelay.hashCode ^
      qualityDelays.hashCode ^
      timeout.hashCode;
}
