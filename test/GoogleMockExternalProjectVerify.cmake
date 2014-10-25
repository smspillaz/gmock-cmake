# /tests/GoogleMockExternalProjectVerify.cmake
# Tests that the test was correctly added and
# built as a result of building it
#
# See LICENCE.md for Copyright information

include (CMakeUnit)
include (GetTargetLocationFromExportsHelper)

set (EXPORTS_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/simpletest-exports.cmake)
get_target_location_from_exports (${EXPORTS_FILE} simple_test TEST_BINARY)

assert_command_executes_with_success (TEST_BINARY)
