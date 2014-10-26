# /tests/FromParentInExternalProjectVerify.cmake
#
# Verify that the built test executable in our external project runs
# as expected
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
include (GetTargetLocationFromExportsHelper)

set (EXTERNAL_PROJECT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/External)
set (EXTERNAL_PROJECT_BINARY_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY}/build)
set (EXPORTS_FILE
     ${EXTERNAL_PROJECT_BINARY_DIRECTORY}/extproj-exports.cmake)
get_target_location_from_exports (${EXPORTS_FILE} simple_test TEST_BINARY)

assert_command_executes_with_success (TEST_BINARY)

set (SUBPROJECT_STAMP_DIR
     ${CMAKE_CURRENT_BINARY_DIR}/ExternalLibraryUsingGTest/src/stamp/)
set (SUBPROJECT_BUILD_LOG
     ${SUBPROJECT_STAMP_DIR}/ExternalLibraryUsingGTest-build-out.log)

set (GMOCK_SUBPROJECT_BINARY_DIR
     ${CMAKE_CURRENT_BINARY_DIR}/GoogleMock/src/build)

set (LINKED_TO_PARENT_GTEST_REGEX
     "^.*simple_test.*${GMOCK_SUBPROJECT_BINARY_DIR}/.*gtest.*$")
set (LINKED_TO_PARENT_GMOCK_REGEX
     "^.*simple_test.*${GMOCK_SUBPROJECT_BINARY_DIR}/.*gmock.*$")
assert_file_has_line_matching (${SUBPROJECT_BUILD_LOG}
                               "${LINKED_TO_PARENT_GTEST_REGEX}")
assert_file_has_line_matching (${SUBPROJECT_BUILD_LOG}
                               "${LINKED_TO_PARENT_GMOCK_REGEX}")