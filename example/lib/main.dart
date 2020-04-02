import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:MessagingTiming/MessagingTiming.dart';
import 'package:MessagingTiming/pigeon.dart';

void main() => runApp(MyApp());

const int _testRunCount = 10000;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _Test {
  final Future<double> Function() run;
  final String message;
  final String name;
  _Test({this.run, this.message, this.name});
}

Iterable<U> _imap<T, U>(
    Iterable<T> list, U Function(int index, T input) mapper) sync* {
  int count = 0;
  for (T value in list) {
    yield mapper(count++, value);
  }
}

Future<double> _measureVoidString(Future<String> Function() func) async {
  double simpleMethodChannel;
  try {
    DateTime start = DateTime.now();
    int count = _testRunCount;
    for (int i = 0; i < count; ++i) {
      await func();
    }
    Duration delta = DateTime.now().difference(start);
    simpleMethodChannel = delta.inMicroseconds / count;
  } catch (ex) {
    print(ex);
    simpleMethodChannel = -1;
  }
  return simpleMethodChannel;
}

Future<double> _calcSimpleMethodChannel() async {
  final MessagingTiming messagingTiming = MessagingTiming();
  return await _measureVoidString(
      () => messagingTiming.methodChannelPlatformVersion);
}

Future<double> _calcBasicMessageChannel() async {
  final MessagingTiming messagingTiming = MessagingTiming();
  return await _measureVoidString(
      () => messagingTiming.basicMessageChannelPlatformVersion);
}

Future<double> _calcBasicMessageChannelBinary() async {
  final MessagingTiming messagingTiming = MessagingTiming();
  return await _measureVoidString(
      () => messagingTiming.basicMessageChannelBinaryPlatformVersion);
}


Future<double> _calcPigeon() async {
  final MessagingTiming messagingTiming = MessagingTiming();
  final Api api = Api();
  return await _measureVoidString(
      () => messagingTiming.getPigeonPlatformVersion(api));
}

Future<double> _calcDart() async {
  return await _measureVoidString(() {
    Completer<String> completer = Completer<String>();
    completer.complete("Just Dart");
    return completer.future;
  });
}

Future<double> _calcFfi() async {
  final MessagingTiming messagingTiming = MessagingTiming();
  return await _measureVoidString(() {
    Completer<String> completer = Completer<String>();
    completer.complete(messagingTiming.getFfiPlatformVersion());
    return completer.future;
  });
}

Future<double> _calcFfiUi() async {
  final MessagingTiming messagingTiming = MessagingTiming();
  return await _measureVoidString(() {
    Completer<String> completer = Completer<String>();
    completer.complete(messagingTiming.getFfiPlatformVersionUi());
    return completer.future;
  });
}

void _ffiRunner(SendPort sendPort) async {
  final MessagingTiming messagingTiming = MessagingTiming();
  var ourReceivePort = ReceivePort();
  sendPort.send(ourReceivePort.sendPort);
  await for (dynamic _ in ourReceivePort) {
    sendPort.send(messagingTiming.getFfiPlatformVersion());
  }
}

Future<double> _calcFfiNonBlocking() async {
  final ReceivePort receivePort = ReceivePort();
  final Completer<SendPort> sendPortCompleter = Completer<SendPort>();
  final Isolate isolate = await Isolate.spawn(_ffiRunner, receivePort.sendPort);
  Completer<String> completer;
  bool sentPort = false;
  receivePort.listen((data) {
    if (!sentPort) {
      sendPortCompleter.complete(data);
      sentPort = true;
    } else {
      completer.complete(data);
    }
  });
  final SendPort sendPort = await sendPortCompleter.future;
  final double result = await _measureVoidString(() {
    completer = Completer<String>();
    sendPort.send(null);
    return completer.future;
  });
  isolate.kill();
  return result;
}

class _MyAppState extends State<MyApp> {
  Map<String, double> _results = {};

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  _Test _makeTest(String name, String label, Future<double> Function() run) {
    return _Test(
      name: name,
      run: run,
      message: '$label: ${_results[name]} µs',
    );
  }

  List<_Test> get _tests {
    return _imap([
      ['simple method channel (1st run)', _calcSimpleMethodChannel],
      ['simple method channel (2nd run)', _calcSimpleMethodChannel],
      ['basic message channel (1st run)', _calcBasicMessageChannel],
      ['basic message channel (2nd run)', _calcBasicMessageChannel],
      ['basic message channel binary (1st run)', _calcBasicMessageChannelBinary],
      ['basic message channel binary (2nd run)', _calcBasicMessageChannelBinary],
      ['pigeon (1st run)', _calcPigeon],
      ['pigeon (2nd run)', _calcPigeon],
      ['ffi', _calcFfi],
      ['ffi non-blocking', _calcFfiNonBlocking],
      ['ffi ui thread', _calcFfiUi],
      ['just Dart', _calcDart],
    ], (int index, List entry) => _makeTest('$index', entry[0], entry[1]))
        .toList();
  }

  Future<void> _runTests() async {
    for (_Test test in _tests) {
      double value = await test.run();
      if (!mounted) return;
      setState(() {
        _results[test.name] = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Messaging Profiler'),
        ),
        body: Center(
          child: ListView(
              children: _imap(_tests, (int index, _Test test) {
            return Container(
              padding: new EdgeInsets.all(5.0),
              height: 50,
              color: Colors.amber[index % 9 * 100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(test.message)],
              ),
            );
          }).toList()),
        ),
      ),
    );
  }
}
