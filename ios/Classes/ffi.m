#include "ffi.h"
#include <Foundation/Foundation.h>

char* GetPlatformVersion(void) {
  __block char* result;
  dispatch_sync(dispatch_get_main_queue(), ^{
    NSString* platformVersion =
      [@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
    result = strdup([platformVersion UTF8String]);
  });
  return result;
}
