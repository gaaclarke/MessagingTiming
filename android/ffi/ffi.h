#pragma once

#ifdef __cplusplus
extern "C" {
#endif

char* GetPlatformVersion(void)
  __attribute__((visibility("default"))) __attribute__((used));

char* GetPlatformVersionUi(void)
  __attribute__((visibility("default"))) __attribute__((used));

#ifdef __cplusplus
}
#endif
