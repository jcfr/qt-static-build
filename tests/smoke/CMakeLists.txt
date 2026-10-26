# Minimal project linking against the static Qt install to check that the
# CMake package is usable and that all static dependencies resolve.
cmake_minimum_required(VERSION 3.22)
project(QtStaticSmokeTest LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Widgets Test)

add_executable(smoke main.cpp)
target_link_libraries(smoke PRIVATE Qt6::Widgets Qt6::Test)
