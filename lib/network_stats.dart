import 'package:data_connection_checker/network_quality.dart';
import 'package:meta/meta.dart';
import 'network_status.dart';

class NetworkStats {
  final NetworkStatus status;
  final Duration minDelay;
  final Duration maxDelay;
  final NetworkQuality minQuality;
  final NetworkQuality maxQuality;

  const NetworkStats({
    @required this.status,
    @required this.minDelay,
    @required this.maxDelay,
    @required this.minQuality,
    @required this.maxQuality,
  });

  @override
  String toString() {
    return 'NetworkStats{status: $status, minDelay: $minDelay, maxDelay: $maxDelay, minQuality: $minQuality, maxQuality: $maxQuality}';
  }
}
