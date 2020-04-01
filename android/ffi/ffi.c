#include "ffi.h"
#include <jni.h>
#include <android/log.h>
#include <string.h>

#define APPNAME "MessagingTimingPlugin"

static JNIEnv *s_env;

jint JNI_OnLoad(JavaVM *vm, void *reserved)
    __attribute__((visibility("default"))) __attribute__((used)) {
  __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "loaded library\n");
  return JNI_VERSION_1_2;
}

JNIEXPORT void JNICALL
Java_com_example_MessagingTiming_MessagingTimingPlugin_setupJni(JNIEnv *env,
                                                                jobject obj)
    __attribute__((visibility("default"))) __attribute__((used)) {
  s_env = env;
  __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "hello\n");
}

char* GetPlatformVersion(void) {
  // TODO: execute on the main thread.
  static const char* s_unknown = "unknown";
  return strdup(s_unknown);
}

char* GetPlatformVersionUi(void) {
  static char* s_cache = "Android: Unknown";
  if (!s_cache) {
    s_cache = GetPlatformVersion();
  }
  return strdup(s_cache);
}
