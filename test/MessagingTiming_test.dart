import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:MessagingTiming/MessagingTiming.dart';

void main() {
  const MethodChannel channel = MethodChannel('MessagingTiming');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await MessagingTiming.platformVersion, '42');
  });
}
