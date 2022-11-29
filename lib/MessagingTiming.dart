// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

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

  final BasicMessageChannel _basicMessageChannelBinary =
      BasicMessageChannel('BasicMessageChannelBinary', BinaryCodec());

  Future<String> get basicMessageChannelPlatformVersion async {
    final String version =
        await _basicMessageChannel.send('getPlatformVersion');
    return version;
  }

  static final ByteBuffer _getPlatformVersionBuffer =
    Uint8List.fromList(utf8.encode("getPlatformVersion")).buffer;
  static final ByteData _getPlatformVersionByteData =
    ByteData.view(_getPlatformVersionBuffer);

  Future<String> get basicMessageChannelBinaryPlatformVersion async {
    final ByteData version =
        await _basicMessageChannelBinary.send(_getPlatformVersionByteData);
    return utf8.decode(version.buffer.asUint8List());
  }

  Future<String> getPigeonPlatformVersion(Api api) async {
    final StringMessage result = await api.getPlatformVersion(VoidMessage());
    return result.message;
  }

  String getFfiPlatformVersion() {
    return _nativeGetPlatformVersion().toDartString();
  }

  String getFfiPlatformVersionUi() {
    return _nativeGetPlatformVersionUi().toDartString();
  }
}
