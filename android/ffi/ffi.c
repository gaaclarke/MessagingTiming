#include "ffi.h"
#include <android/log.h>
#include <assert.h>
#include <jni.h>
#include <string.h>

#define APPNAME "MessagingTimingPlugin"

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
  JNIEnv *env = NULL;
  jint err = (*s_vm)->AttachCurrentThread(s_vm, &env, NULL);
  assert(err == JNI_OK);
  static jmethodID s_method = NULL;
  if (!s_method) {
    s_method = (*env)->GetStaticMethodID(env, s_MessagingTimingPlugin,
                                         "getPlatformVersionMainThread",
                                         "()Ljava/lang/String;");
    assert((*env)->ExceptionCheck(env) == JNI_FALSE);
  }
  assert(s_method);
  jstring obj =
      (*env)->CallStaticObjectMethod(env, s_MessagingTimingPlugin, s_method);
  assert((*env)->ExceptionCheck(env) == JNI_FALSE);
  assert(obj);
  char *jresult = (*env)->GetStringUTFChars(env, obj, /*isCopy=*/NULL);
  assert(jresult);
  char *result = strdup(jresult);
  assert(result);
  (*env)->ReleaseStringUTFChars(env, obj, jresult);
  (*env)->DeleteLocalRef(env, obj);

  return result;
}

char *GetPlatformVersionUi(void) {
  static JNIEnv *s_env = NULL;
  static jmethodID s_method;
  if (!s_env) {
    assert(s_vm);
    jint err = (*s_vm)->AttachCurrentThread(s_vm, &s_env, NULL);
    assert(err == JNI_OK);
    s_method = (*s_env)->GetStaticMethodID(s_env, s_MessagingTimingPlugin,
                                           "getPlatformVersion",
                                           "()Ljava/lang/String;");
    assert((*s_env)->ExceptionCheck(s_env) == JNI_FALSE);
  }
  assert(s_method);
  jstring obj = (*s_env)->CallStaticObjectMethod(s_env, s_MessagingTimingPlugin,
                                                 s_method);
  assert((*s_env)->ExceptionCheck(s_env) == JNI_FALSE);
  assert(obj);
  char *jresult = (*s_env)->GetStringUTFChars(s_env, obj, /*isCopy=*/NULL);
  assert(jresult);
  char *result = strdup(jresult);
  assert(result);
  (*s_env)->ReleaseStringUTFChars(s_env, obj, jresult);
  (*s_env)->DeleteLocalRef(s_env, obj);

  return result;
}
