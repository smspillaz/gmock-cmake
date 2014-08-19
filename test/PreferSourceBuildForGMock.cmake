# /tests/PreferSourceBuildForGMock.cmake
#
# Check that upon setting GMOCK_PREFER_SOURCE_BUILD
# we can still build a usable google-mock
#
# See LICENCE.md for Copyright information.

include (${GMOCK_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)
set (CMAKE_MODULE_PATH ${GMOCK_CMAKE_DIRECTORY} ${CMAKE_MODULE_PATH})

set (GMOCK_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
find_package (GoogleMock REQUIRED)

include (${GMOCK_CMAKE_TESTS_DIRECTORY}/AddSimpleGTestHelper.cmake)