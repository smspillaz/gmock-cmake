# /tests/AlwaysDownloadSourcesCreatesExternalProjectVerify.cmake
#
# Checks that the external project directory ${CMAKE_CURRENT_BINARY_DIR}/__gmock
# is created on setting and building with GMOCK_ALWAYS_DOWNLOAD_SOURCES
#
# See LICENCE.md for Copyright information.

include (${GMOCK_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)

assert_file_exists (${CMAKE_CURRENT_BINARY_DIR}/__gmock)