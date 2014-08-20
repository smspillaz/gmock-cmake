# /tests/DownloadSVNRunsSVNCheckoutVerify.cmake
#
# Checks that on setting GMOCK_DOWNLOAD_VERSION to "SVN"
# we run "svn checkout"
#
# See LICENCE.md for Copyright information.

include (${GMOCK_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)
set (GOOGLE_MOCK_SVN_REPOSITORY "http://googlemock.googlecode.com/svn/trunk")
assert_file_has_line_matching (${BUILD_OUTPUT_FILE} "^.*svn.*co.*${GOOGLE_MOCK_SVN_REPOSITORY}.*$")