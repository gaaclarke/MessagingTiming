#include "ffi.h"
#include <jni.h>

char* GetPlatformVersion(void) {
  // TODO: execute on the main thread.
  static const char* s_unknown = "unknown";
  return strdup(s_unknown);
}

char* GetPlatformVersionUi(void) {
  static char* s_cache;
  if (!s_cache) {
    s_cache = GetPlatformVersion();
  }
  return strdup(s_cache);
}
