# /tests/GoogleMockExternalProject.cmake
# Tests that GMock can be built as an external project
# and linked to.
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

find_package (GoogleMock REQUIRED)

include (AddSimpleGTestHelper)