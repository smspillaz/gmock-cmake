# /tests/ForceUpdatesOptionAllowsUpdate.cmake
#
# Checks that on setting GMOCK_DOWNLOAD_VERSION to "SVN"
# and GMOCK_FORCE_UPDATE to ON that "svn up" is run.
#
# See LICENCE.md for Copyright information.

include (${GMOCK_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)
set (CMAKE_MODULE_PATH ${GMOCK_CMAKE_DIRECTORY} ${CMAKE_MODULE_PATH})

set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
set (GMOCK_DOWNLOAD_VERSION "SVN" CACHE STRING "" FORCE)
set (GMOCK_FORCE_UPDATE ON CACHE BOOL "" FORCE)
find_package (GoogleMock REQUIRED)

include (${GMOCK_CMAKE_TESTS_DIRECTORY}/AddSimpleGTestHelper.cmake)