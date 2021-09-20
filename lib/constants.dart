import 'dart:io';

import 'network_check_options.dart';

const int defaultBufferCapacity = 2;

///
const Duration defaultMinimumQualityDelay = Duration(milliseconds: 100);

/// Default interval is 10 seconds
///
/// Interval is the time between automatic checks
const Duration defaultCheckInterval = Duration(seconds: 5);

/// More info on why default port is 53
/// here:
/// - https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
/// - https://www.google.com/search?q=dns+server+port
const int defaultPort = 53;

/// More info on why default secure port is 443
/// here:
/// - https://github.com/komapeb/data_connection_checker/issues/12
/// - https://flutter.dev/docs/release/breaking-changes/network-policy-ios-android
const int defaultSecurePort = 443;

/// Default timeout is 10 seconds.
///
/// Timeout is the number of seconds before a request is dropped
/// and an address is considered unreachable
const Duration defaultTimeout = Duration(seconds: 10);

/// Predefined reliable addresses. This is opinionated
/// but should be enough. See https://www.dnsperf.com/#!dns-resolvers
///
/// Addresses info:
///
/// <!-- kinda hackish ^_^ -->
/// <style>
/// table {
///   width: 100%;
///   border-collapse: collapse;
/// }
/// th, td { padding: 5px; border: 1px solid lightgrey; }
/// thead { border-bottom: 2px solid lightgrey; }
/// </style>
///
/// | Address        | Provider   | Info                                            |
/// |:---------------|:-----------|:------------------------------------------------|
/// | 1.1.1.1        | CloudFlare | https://1.1.1.1                                 |
/// | 1.0.0.1        | CloudFlare | https://1.1.1.1                                 |
/// | 8.8.8.8        | Google     | https://developers.google.com/speed/public-dns/ |
/// | 8.8.4.4        | Google     | https://developers.google.com/speed/public-dns/ |
/// | 208.67.222.222 | OpenDNS    | https://use.opendns.com/                        |
/// | 208.67.220.220 | OpenDNS    | https://use.opendns.com/                        |
final defaultCheckOptions = Set.unmodifiable([
  NetworkCheckOptions(
    InternetAddress('8.8.8.8', type: InternetAddressType.IPv4), // Google
  ),
  NetworkCheckOptions(
    InternetAddress('2001:4860:4860::8888', type: InternetAddressType.IPv6), // Google
  ),
  NetworkCheckOptions(
    InternetAddress('1.1.1.1', type: InternetAddressType.IPv4), // CloudFlare
  ),
  NetworkCheckOptions(
    InternetAddress('2606:4700:4700::1111', type: InternetAddressType.IPv6), // CloudFlare
  ),
  NetworkCheckOptions(
    InternetAddress('208.67.222.222', type: InternetAddressType.IPv4), // OpenDNS
  ),
  // NetworkCheckOptions(
  //   InternetAddress('180.76.76.76', type: InternetAddressType.IPv4), // Baidu
  // ),
  // NetworkCheckOptions(
  //   InternetAddress('2400:da00::6666', type: InternetAddressType.IPv6), // Baidu
  // ),
]);
