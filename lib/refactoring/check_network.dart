import 'dart:io';

import 'package:data_connection_checker/refactoring/constants.dart';
import 'package:data_connection_checker/refactoring/options.dart';

import 'result.dart';

abstract class NetworkCheck {
  NetworkCheckOptions get _options;

  factory NetworkCheck.fromOptions(NetworkCheckOptions options) {
    return options.secured
        ? SecuredNetworkCheck(options: options)
        : UnsecuredNetworkCheck(options: options);
  }

  factory NetworkCheck.from(
    InternetAddress address, {
    int? port,
    Duration timeout = defaultTimeout,
    bool secured = true,
  }) {
    final options = NetworkCheckOptions(
      address,
      port: port,
      secured: secured,
      timeout: timeout,
    );
    return secured
        ? SecuredNetworkCheck(options: options)
        : UnsecuredNetworkCheck(options: options);
  }

  InternetAddress get address => _options.address;

  int get port => _options.port;

  Duration get timeout => _options.timeout;

  Future<Socket> _createSocket();

  Future<NetworkCheckResult> call() async {
    final checkResult = NetworkCheckResult(options: _options);
    final futureSocket = _createSocket();
    final maybeSocket = await checkResult.measure(
      () async => await futureSocket,
    );
    maybeSocket?.destroy();
    return checkResult;
  }
}

class UnsecuredNetworkCheck with NetworkCheck {
  @override
  final NetworkCheckOptions _options;

  const UnsecuredNetworkCheck({
    required NetworkCheckOptions options,
  }) : _options = options;

  @override
  Future<Socket> _createSocket() {
    return Socket.connect(address, port, timeout: timeout);
  }
}

class SecuredNetworkCheck with NetworkCheck {
  @override
  final NetworkCheckOptions _options;

  const SecuredNetworkCheck({
    required NetworkCheckOptions options,
  }) : _options = options;

  @override
  Future<Socket> _createSocket() {
    return SecureSocket.connect(address, port, timeout: timeout);
  }
}
