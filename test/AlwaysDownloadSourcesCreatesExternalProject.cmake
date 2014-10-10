# /tests/AlwaysDownloadSourcesCreatesExternalProject.cmake
#
# Checks that when we set the GMOCK_ALWAYS_DOWNLOAD_SOURCES
# option that an external project is created called 'GoogleMock'
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
find_package (GoogleMock REQUIRED)

include (AddSimpleGTestHelper)