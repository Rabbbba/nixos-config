cmake_minimum_required(VERSION 3.21)

project( NativeSensors
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
      native_ram.h
      native_ram.cpp
)

include(CTest)

if(BUILD_TESTING)
  find_package(Qt6
    REQUIRED
    COMPONENTS
    Test
  )

  add_executable(test-native-ram
    tests/test_native_ram.cpp
    native_ram.cpp
    native_ram.h
    native_sensor.cpp
    native_sensor.h
  )

  target_link_libraries(test-native-ram
    PRIVATE
      Qt6::Core
      Qt6::Qml
      Qt6::Test
  )

  target_compile_definitions(test-native-ram
    PRIVATE
      TEST_FIXTURE_PROC_ROOT="${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/proc"
  )

  add_test(NAME native-ram COMMAND test-native-ram)

  add_executable(test-native-network
    tests/test_native_network.cpp
    native_network.cpp
    native_network.h
    native_sensor.cpp
    native_sensor.h
  )

  target_link_libraries(test-native-network
    PRIVATE
      Qt6::Core
      Qt6::Qml
      Qt6::Test
  )

  target_compile_definitions(test-native-network
    PRIVATE
      TEST_FIXTURE_NETWORK_ROOT="${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/network"
  )

  add_test(NAME native-network COMMAND test-native-network)
endif()
