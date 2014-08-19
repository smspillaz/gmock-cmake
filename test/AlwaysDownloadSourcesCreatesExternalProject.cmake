# /tests/AlwaysDownloadSourcesCreatesExternalProject.cmake
#
# Checks that when we set the GMOCK_ALWAYS_DOWNLOAD_SOURCES
# option that an external project is created called 'GoogleMock'
#
# See LICENCE.md for Copyright information.

include (${GMOCK_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)
set (CMAKE_MODULE_PATH ${GMOCK_CMAKE_DIRECTORY} ${CMAKE_MODULE_PATH})

set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
find_package (GoogleMock REQUIRED)

include (${GMOCK_CMAKE_TESTS_DIRECTORY}/AddSimpleGTestHelper.cmake)