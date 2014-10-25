# /tests/CheckForCompilerFlagsVerify.cmake
#
# Checks that the following compiler flags, if avaialable, are present:
# - -Wno-unused-private-field
# - -Wno-missing-field-initializers
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (GMOCK_STAMP_DIR
     ${CMAKE_CURRENT_BINARY_DIR}/GoogleMock/src/stamp)
set (BUILD_OUTPUT ${GMOCK_STAMP_DIR}/GoogleMock-build-out.log)

if (HAVE_GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD)

    assert_file_has_line_matching (${BUILD_OUTPUT}
                                   "^.*Wno-unused-private-field.*$")

endif (HAVE_GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD)

if (HAVE_GMOCK_NO_ERROR_MISSING_FIELD_INITIALIZERS)

    assert_file_has_line_matching (${BUILD_OUTPUT}
                                   "^.*Wno-missing-field-initializers.*$")

endif (HAVE_GMOCK_NO_ERROR_MISSING_FIELD_INITIALIZERS)

if (HAVE_GMOCK_FORCE_CXX98_FLAG)

    assert_file_has_line_matching (${BUILD_OUTPUT}
                                   "^.*std.c..98.*$")

endif (HAVE_GMOCK_FORCE_CXX98_FLAG)
