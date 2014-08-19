# /tests/DownloadSVNDoesNotUpdateByDefaultVerify.cmake
#
# Checks that on setting GMOCK_DOWNLOAD_VERSION to "SVN"
# we don't run "svn up" by default.
#
# See LICENCE.md for Copyright information.

include (${GMOCK_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)
assert_file_does_not_have_line_matching (${BUILD_OUTPUT_FILE} "^.*svn.*up.*$")