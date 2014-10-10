# /tests/DownloadSVNRunsSVNCheckout.cmake
#
# Checks that on setting GMOCK_DOWNLOAD_VERSION to "SVN"
# we run "svn checkout"
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
set (GMOCK_DOWNLOAD_VERSION "SVN" CACHE STRING "" FORCE)
find_package (GoogleMock REQUIRED)

include (AddSimpleGTestHelper)