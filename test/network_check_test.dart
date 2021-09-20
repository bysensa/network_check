import 'dart:async';
import 'dart:isolate';

import 'package:data_connection_checker/constants.dart';
import 'package:data_connection_checker/network_check.dart';
import 'package:data_connection_checker/network_check_completer.dart';
import 'package:test/test.dart';

void main() async {
  group('data_connection_checker', () {
    test('should check reachability for host', () async {
      final option = defaultCheckOptions.first;
      final result = await isHostReachable(option);
      expect(result.isSuccess, isTrue);
      print(result);
    });

    test('should check reachability for hosts', () async {
      final options = defaultCheckOptions;
      final results = await isHostsReachable(options);
      for (final result in results) {
        print(result);
      }
    });

    test('should instantiate', () {
      final instance = NetworkCheck();
    });

    test('should provide stats', () async {
      final instance = NetworkCheck(
        checkInterval: Duration(seconds: 1),
        minimumQualityDelay: Duration(milliseconds: 3),
      );
      final completer = NetworkCheckCompleter();
      final statsStream = instance.checkNetwork(completer);
      print(statsStream.runtimeType);
      statsStream.forEach(print);
      await Future.delayed(Duration(seconds: 20), () => completer.complete());
    });

    test('should provide stats once', () async {
      final instance = NetworkCheck(
        checkInterval: Duration(seconds: 1),
        minimumQualityDelay: Duration(milliseconds: 3),
      );
      final completer = NetworkCheckCompleter();
      print(instance.checkNetwork(completer).first);

      await Future.delayed(Duration(seconds: 20), () => completer.complete());
    });
  });
}
