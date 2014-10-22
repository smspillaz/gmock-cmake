# /tests/CompilerFlagsPassedForSourceBuildOfGTest.cmake
#
# Check that upon setting GTEST_PREFER_SOURCE_BUILD
# we can still build a usable google-mock
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (GTEST_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
find_package (GoogleMock REQUIRED)

include (AddSimpleGTestHelper)
