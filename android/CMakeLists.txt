cmake_minimum_required(VERSION 3.4.1)  # for example

add_library( native_add
             # Sets the library as a shared library.
             SHARED
             # Provides a relative path to your source file(s).
             ffi/ffi.c )

find_library(LOG_LIB NAMES log)
find_library(ANDROID_LIB NAMES android)
find_library(DL_LIB NAMES dl)

target_link_libraries( # Specifies the target library.
                       native_add
                       # Links the target library to the log library
                       # included in the NDK.
                       ${LOG_LIB}
                       ${ANDROID_LIB}
                       ${DL_LIB} )