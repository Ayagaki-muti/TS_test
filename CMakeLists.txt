cmake_minimum_required(VERSION 3.21)
project(untitled)

set(CMAKE_CXX_STANDARD 14)
include(gmssl.cmake)

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-stack-protector")

add_executable(untitled main.cpp)
target_link_libraries(untitled PUBLIC openssl) #sqlite3 crypto
