# /tests/AlwaysDownloadSourcesCreatesExternalProjectVerify.cmake
#
# Checks that the external project directory
# ${CMAKE_CURRENT_BINARY_DIR}/GoogleMock
# is created on setting and building with GMOCK_ALWAYS_DOWNLOAD_SOURCES
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

assert_file_exists (${CMAKE_CURRENT_BINARY_DIR}/GoogleMock)