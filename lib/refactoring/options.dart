import 'dart:io';

import 'constants.dart';

/// This class should be pretty self-explanatory.
/// If [NetworkCheckOptions.port]
/// or [NetworkCheckOptions.timeout] are not specified, they both
/// default to [NetworkCheck.defaultPort]
/// and [NetworkCheck.defaultTimeout]
/// Also... yeah, I'm not great at naming things.
class NetworkCheckOptions {
  final InternetAddress address;
  final int port;
  final Duration timeout;
  final bool secured;

  const NetworkCheckOptions(
    this.address, {
    bool secured = true,
    int? port,
    this.timeout = defaultTimeout,
  })  : secured = secured,
        port = port ?? (secured ? defaultSecurePort : defaultPort);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkCheckOptions &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          port == other.port &&
          secured == other.secured &&
          timeout == other.timeout;

  @override
  int get hashCode =>
      address.hashCode ^ port.hashCode ^ secured.hashCode ^ timeout.hashCode;

  @override
  String toString() {
    return 'NetworkCheckOptions{address: $address, port: $port, timeout: $timeout, secured: $secured}';
  }
}
