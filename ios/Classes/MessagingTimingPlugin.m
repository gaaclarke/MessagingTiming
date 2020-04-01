// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MessagingTimingPlugin.h"
#import "pigeon.h"

@interface MyApi : NSObject <PGNApi>
@end

@implementation MyApi
- (PGNStringMessage *)getPlatformVersion:(PGNVoidMessage *)input
                                   error:(FlutterError **)error {
  PGNStringMessage *result = [[PGNStringMessage alloc] init];
  result.message = [@"iOS "
      stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
  return result;
}
@end

@implementation MessagingTimingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
//  typedef int32_t (*native_add_t)(int32_t, int32_t);
//  static volatile native_add_t native_add_var = &native_add;

  {
    FlutterMethodChannel *channel =
        [FlutterMethodChannel methodChannelWithName:@"MessagingTiming"
                                    binaryMessenger:[registrar messenger]];
    MessagingTimingPlugin *instance = [[MessagingTimingPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
  }
  {
    FlutterBasicMessageChannel *basicMessageChannel =
        [FlutterBasicMessageChannel messageChannelWithName:@"BasicMessageChannel"
                                           binaryMessenger:[registrar messenger]];
    [basicMessageChannel
        setMessageHandler:^(id _Nullable message, FlutterReply callback) {
          if ([message isEqualToString:@"getPlatformVersion"]) {
            callback([@"iOS " stringByAppendingString:[[UIDevice currentDevice]
                                                          systemVersion]]);
          } else {
            callback(nil);
          }
        }];
  }
  {
    FlutterBasicMessageChannel *basicMessageChannelBinary =
        [FlutterBasicMessageChannel messageChannelWithName:@"BasicMessageChannelBinary"
                                           binaryMessenger:[registrar messenger]
                                           codec:[FlutterBinaryCodec sharedInstance]];
    NSString* getPlatformVersion = @"getPlatformVersion";
    NSData* getPlatformVersionData = [getPlatformVersion dataUsingEncoding:kCFStringEncodingUTF8];
    [basicMessageChannelBinary
        setMessageHandler:^(NSData* _Nullable message, FlutterReply callback) {
          if ([message isEqualToData:getPlatformVersionData]) {
            NSString* result =
                [@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
            callback([result dataUsingEncoding:kCFStringEncodingUTF8]);
          } else {
            callback(nil);
          }
        }];
  }

  PGNApiSetup([registrar messenger], [[MyApi alloc] init]);
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS "
        stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
