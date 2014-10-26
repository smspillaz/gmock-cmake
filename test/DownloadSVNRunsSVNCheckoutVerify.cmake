# /tests/DownloadSVNRunsSVNCheckoutVerify.cmake
#
# Checks that on setting GMOCK_DOWNLOAD_VERSION to "SVN"
# we run "svn checkout"
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (METAPROJECT_BINARY_DIR
     ${CMAKE_CURRENT_BINARY_DIR}/GoogleMock/GoogleMock-Meta/build)
set (BUILD_METAPROJECT_OUTPUT_FILE
     ${METAPROJECT_BINARY_DIR}/BuildMetaProjectOutput.txt)
set (GOOGLE_MOCK_SVN_REPOSITORY "http://googlemock.googlecode.com/svn/trunk")
assert_file_has_line_matching (${BUILD_METAPROJECT_OUTPUT_FILE}
                               "^.*svn.*co.*${GOOGLE_MOCK_SVN_REPOSITORY}.*$")