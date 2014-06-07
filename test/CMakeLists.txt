# /tests/CMakeLists.txt
# Main entry point for the gmock-cmake tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)

project (GMockCMakeTests)
cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (GMOCK_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (GMOCK_CMAKE_DIRECTORY
                        ${GMOCK_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)

set (CMAKE_UNIT_DIRECTORY
     ${GMOCK_CMAKE_DIRECTORY}/cmake-unit)

# Put our directories into the cache
set (GMOCK_CMAKE_INITIAL_CACHE_CONTENTS
     "set (GMOCK_CMAKE_DIRECTORY\n"
     "     ${GMOCK_CMAKE_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (GMOCK_CMAKE_TESTS_DIRECTORY\n"
     "     ${CMAKE_UNIT_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (GMOCK_CMAKE_GENERATOR\n"
     "     ${CMAKE_GENERATOR}\n"
     "     CACHE STRING \"\" FORCE)\n")

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)

bootstrap_cmake_unit (INITIAL_CACHE_CONTENTS
                      GMOCK_CMAKE_INITIAL_CACHE_CONTENTS)

add_cmake_build_test (GoogleMockExternalProject
                      GoogleMockExternalProjectVerify)
