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
  final bool secured;

  const NetworkCheckOptions(
    this.address, {
    bool secured = true,
    int port,
  })  : secured = secured ?? true,
        port = port ?? ((secured ?? true) ? defaultSecurePort : defaultPort);

  @override
  String toString() => 'NetworkCheckOptions($address, $port)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkCheckOptions &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          port == other.port &&
          secured == other.secured;

  @override
  int get hashCode => address.hashCode ^ port.hashCode ^ secured.hashCode;
}
