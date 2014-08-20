# /tests/GetBuildDirectorySuffixForGeneratorHelper.cmake
# Workaround for some generators setting a different output directory
#
# See LICENCE.md for Copyright information

function (_get_build_directory_suffix_for_generator SUFFIX)

    if (GMOCK_CMAKE_GENERATOR STREQUAL "Xcode")

        if (CMAKE_BUILD_TYPE)

            set (${SUFFIX} ${CMAKE_BUILD_TYPE} PARENT_SCOPE)

        else (CMAKE_BUILD_TYPE)

            set (${SUFFIX} "Debug" PARENT_SCOPE)

        endif (CMAKE_BUILD_TYPE)

    endif (GMOCK_CMAKE_GENERATOR STREQUAL "Xcode")

endfunction (_get_build_directory_suffix_for_generator)