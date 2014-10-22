# GoogleMockLibraryUtils.cmake
#
# CMake Helper library to check for some relevant compiler flags
#
# See LICENCE.md for Copyright information.

include (CheckCXXCompilerFlag)

set (GMOCK_CXX_FLAGS "")

set (GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD_FLAG "-Wno-unused-private-field")
set (GMOCK_NO_ERROR_MISSING_FIELD_INITIALIZERS_FLAG
     "-Wno-missing-field-initializers")
set (GMOCK_FORCE_CXX98_FLAG "-std=c++98")

check_cxx_compiler_flag ("${GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD_FLAG}"
                         HAVE_GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD)
check_cxx_compiler_flag ("${GMOCK_NO_ERROR_MISSING_FIELD_INITIALIZERS_FLAG}"
                         HAVE_GMOCK_NO_ERROR_MISSING_FIELD_INITIALIZERS)
check_cxx_compiler_flag ("${GMOCK_FORCE_CXX98_FLAG}"
                         HAVE_GMOCK_FORCE_CXX98_FLAG)
