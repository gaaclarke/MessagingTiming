#include "ffi.h"
#include <android/log.h>
#include <assert.h>
#include <jni.h>
#include <string.h>

#define APPNAME "MessagingTimingPlugin"

static JNIEnv *s_env;
static JavaVM *s_vm;
static jclass s_MessagingTimingPlugin;

JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved)
    __attribute__((visibility("default"))) __attribute__((used)) {
  __android_log_print(ANDROID_LOG_INFO, APPNAME, "loaded library\n");
  s_vm = vm;

  JNIEnv *env;
  int status = (*s_vm)->AttachCurrentThread(s_vm, &env, NULL);
  assert(status == JNI_OK);
  jclass klass = (*env)->FindClass(
      env, "com/example/MessagingTiming/MessagingTimingPlugin");
  assert(klass);
  s_MessagingTimingPlugin = (*env)->NewGlobalRef(env, klass);
  assert(s_MessagingTimingPlugin);

  return JNI_VERSION_1_2;
}

char *GetPlatformVersion(void) {
  if (!s_env) {
    assert(s_vm);
    jint err = (*s_vm)->AttachCurrentThread(s_vm, &s_env, NULL);
    assert(err == JNI_OK);
  }
  jmethodID method =
      (*s_env)->GetStaticMethodID(s_env, s_MessagingTimingPlugin,
                                  "getPlatformVersionMainThread", "()Ljava/lang/String;");
  assert(method);
  jstring obj =
      (*s_env)->CallStaticObjectMethod(s_env, s_MessagingTimingPlugin, method);
  assert(obj);
  (*s_env)->DeleteLocalRef(s_env, method);
  char *jresult = (*s_env)->GetStringUTFChars(s_env, obj, /*isCopy=*/NULL);
  assert(jresult);
  char *result = strdup(jresult);
  assert(result);
  (*s_env)->ReleaseStringUTFChars(s_env, obj, jresult);
  (*s_env)->DeleteLocalRef(s_env, obj);

  return result;
}

char *GetPlatformVersionUi(void) {
  if (!s_env) {
    assert(s_vm);
    jint err = (*s_vm)->AttachCurrentThread(s_vm, &s_env, NULL);
    assert(err == JNI_OK);
  }
  jmethodID method =
      (*s_env)->GetStaticMethodID(s_env, s_MessagingTimingPlugin,
                                  "getPlatformVersion", "()Ljava/lang/String;");
  assert(method);
  jstring obj =
      (*s_env)->CallStaticObjectMethod(s_env, s_MessagingTimingPlugin, method);
  assert(obj);
  (*s_env)->DeleteLocalRef(s_env, method);
  char *jresult = (*s_env)->GetStringUTFChars(s_env, obj, /*isCopy=*/NULL);
  assert(jresult);
  char *result = strdup(jresult);
  assert(result);
  (*s_env)->ReleaseStringUTFChars(s_env, obj, jresult);
  (*s_env)->DeleteLocalRef(s_env, obj);

  return result;
}
