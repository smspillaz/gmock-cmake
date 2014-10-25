# /tests/ForceUpdatesOptionAllowsUpdateVerify.cmake
#
# Checks that on setting GMOCK_DOWNLOAD_VERSION to "SVN"
# and GMOCK_FORCE_UPDATE to ON "svn up" is run again.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (METAPROJECT_BINARY_DIR
     ${CMAKE_CURRENT_BINARY_DIR}/GoogleMock/GoogleMock-Meta/build)
set (BUILD_METAPROJECT_OUTPUT_FILE
     ${METAPROJECT_BINARY_DIR}/BuildMetaProjectOutput.txt)
assert_file_has_line_matching (${BUILD_METAPROJECT_OUTPUT_FILE}
                               "^.*svn.*up.*$")