# /tests/FromParentInExternalProjectVerify.cmake
#
# Verify that the built test executable in our external project runs
# as expected
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (GetBuildDirectorySuffixForGeneratorHelper)

set (BUILD_SUFFIX)
_get_build_directory_suffix_for_generator (BUILD_SUFFIX)

set (EXTERNAL_PROJECT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/External)
set (EXTERNAL_PROJECT_BINARY_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY}/build)
set (TEST_BINARY ${EXTERNAL_PROJECT_BINARY_DIRECTORY}/${BUILD_SUFFIX}/simple_test)
assert_command_executes_with_success (TEST_BINARY)