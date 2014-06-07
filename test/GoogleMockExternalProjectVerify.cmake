# /tests/GoogleMockExternalProjectVerify.cmake
# Tests that the test was correctly added and
# built as a result of building it
#
# See LICENCE.md for Copyright information

include (${GMOCK_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

# Workaround for some generators setting a different output directory
function (_get_build_directory_suffix_for_generator SUFFIX)

    if (GMOCK_CMAKE_GENERATOR STREQUAL "Xcode")

        if (CMAKE_BUILD_TYPE)

            set (${SUFFIX} ${CMAKE_BUILD_TYPE} PARENT_SCOPE)

        else (CMAKE_BUILD_TYPE)

            set (${SUFFIX} "Debug" PARENT_SCOPE)

        endif (CMAKE_BUILD_TYPE)

    endif (GMOCK_CMAKE_GENERATOR STREQUAL "Xcode")

endfunction (_get_build_directory_suffix_for_generator)

set (BUILD_SUFFIX)
_get_build_directory_suffix_for_generator (BUILD_SUFFIX)

set (TEST_BINARY ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_SUFFIX}/simple_test)
assert_command_executes_with_success (TEST_BINARY)
