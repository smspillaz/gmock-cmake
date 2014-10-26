# /tests/DownloadVersion170UnpacksReleaseTarballVerify.cmake
#
# Checks that on setting GMOCK_DOWNLOAD_VERSION to "1.7.0" we have
# a ${CMAKE_BINARY_DIRECTORY}/GoogleMock/src/gmock-1.7.0.zip
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (GMOCK_PROJECT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/GoogleMock)
assert_file_exists (${GMOCK_PROJECT_DIRECTORY}/src/gmock-1.7.0.zip)