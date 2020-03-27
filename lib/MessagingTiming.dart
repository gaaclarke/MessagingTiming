// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';

import 'pigeon.dart';

final DynamicLibrary _nativeAddLib = Platform.isAndroid
    ? DynamicLibrary.open("libnative_add.so")
    : DynamicLibrary.process();

typedef GetPlatformVersionNativeFunc = Pointer<Utf8> Function();
typedef GetPlatformVersionDartFunc = Pointer<Utf8> Function();

final GetPlatformVersionDartFunc _nativeGetPlatformVersion =
  _nativeAddLib
    .lookup<NativeFunction<GetPlatformVersionNativeFunc>>("GetPlatformVersion")
    .asFunction<GetPlatformVersionDartFunc>();

final GetPlatformVersionDartFunc _nativeGetPlatformVersionUi =
  _nativeAddLib
    .lookup<NativeFunction<GetPlatformVersionNativeFunc>>("GetPlatformVersionUi")
    .asFunction<GetPlatformVersionDartFunc>();


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

  String getFfiPlatformVersion() {
    return Utf8.fromUtf8(_nativeGetPlatformVersion());
  }

  String getFfiPlatformVersionUi() {
    return Utf8.fromUtf8(_nativeGetPlatformVersionUi());
  }
}
