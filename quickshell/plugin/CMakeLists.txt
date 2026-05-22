cmake_minimum_required(VERSION 3.21)

project( Hwmon
        VERSION 1.0
        LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6
  REQUIRED
  COMPONENTS
  Core
  Qml
)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_qml_module(quickshell-native-sensors
  URI NativeSensors
  OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/NativeSensors
  VERSION 1.0
  SOURCES
      native_hwmon.cpp
      native_hwmon.h
      native_network.cpp
      native_network.h
      native_sensor.cpp
      native_sensor.h
)
