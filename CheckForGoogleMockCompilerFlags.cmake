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

# Adds a flag to CXXFLAGS_VARIABLE if it is supported by the current compiler.
function (_gmock_add_cxx_flag FLAG_VARIABLE CXXFLAGS_VARIABLE)

    check_cxx_compiler_flag ("${${FLAG_VARIABLE}}" HAVE_${FLAG_VARIABLE})
    if (HAVE_${FLAG_VARIABLE})

        set (${CXXFLAGS_VARIABLE}
             "${${CXXFLAGS_VARIABLE}} ${${FLAG_VARIABLE}}" PARENT_SCOPE)

    endif (HAVE_${FLAG_VARIABLE})

endfunction (_gmock_add_cxx_flag)

_gmock_add_cxx_flag (GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD_FLAG GMOCK_CXX_FLAGS)
_gmock_add_cxx_flag (GMOCK_FORCE_CXX98_FLAG GMOCK_CXX_FLAGS)
_gmock_add_cxx_flag (GMOCK_NO_ERROR_MISSING_FIELD_INITIALIZERS_FLAG
                     GMOCK_CXX_FLAGS)