# /tests/CompilerFlagsPassedForExternalProjectBuild.cmake
#
# Checks that on setting GMOCK_DOWNLOAD_VERSION to "1.70"
# that we download the released version of Google Mock
# and not the SVN version.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
set (GMOCK_DOWNLOAD_VERSION "1.7.0" CACHE STRING "" FORCE)
find_package (GoogleMock REQUIRED)

include (AddSimpleGTestHelper)
