// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon_lib.dart';

class VoidMessage {}

class StringMessage {
  String message;
}

@HostApi()
abstract class Api {
  StringMessage getPlatformVersion(VoidMessage msg);
}

void setupPigeon(PigeonOptions opts) {
  opts.dartOut = 'lib/pigeon.dart';
  opts.objcHeaderOut = 'ios/Classes/pigeon.h';
  opts.objcSourceOut = 'ios/Classes/pigeon.m';
  opts.objcOptions.prefix = 'PGN';
  opts.javaOut = 'android/src/main/java/com/example/MessagingTiming/Pigeon.java';
  opts.javaOptions.package = 'com.example.MessagingTiming';
}
