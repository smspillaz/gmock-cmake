# /tests/GoogleMockExternalProject.cmake
# Tests that GMock can be built as an external project
# and linked to.
#
# See LICENCE.md for Copyright information

include (${GMOCK_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)
set (CMAKE_MODULE_PATH ${GMOCK_CMAKE_DIRECTORY} ${CMAKE_MODULE_PATH})

find_package (GoogleMock REQUIRED)

include (${GMOCK_CMAKE_TESTS_DIRECTORY}/AddSimpleGTestHelper.cmake)