// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import 'pigeon.dart';

class MessagingTiming {
  final MethodChannel _methodChannel = const MethodChannel('MessagingTiming');

  Future<String> get methodChannelPlatformVersion async {
    final String version =
        await _methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  final BasicMessageChannel _basicMessageChannel =
      BasicMessageChannel('BasicMessageChannel', StandardMessageCodec());

  Future<String> get basicMessageChannelPlatformVersion async {
    final String version =
        await _basicMessageChannel.send('getPlatformVersion');
    return version;
  }

  Future<String> getPigeonPlatformVersion(Api api) async {
    final StringMessage result = await api.getPlatformVersion(VoidMessage());
    return result.message;
  }
}
