cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(sysres_library LANGUAGES C)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/build)
add_library(sysres SHARED cpu.c memory.c)
