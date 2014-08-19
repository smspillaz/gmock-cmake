# /tests/ForceUpdatesOptionAllowsUpdateVerify.cmake
#
# Checks that on setting GMOCK_DOWNLOAD_VERSION to "SVN"
# and GMOCK_FORCE_UPDATE to ON "svn up" is run again.
#
# See LICENCE.md for Copyright information.

include (${GMOCK_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)
assert_file_has_line_matching (${BUILD_OUTPUT_FILE} "^.*svn.*up.*$")