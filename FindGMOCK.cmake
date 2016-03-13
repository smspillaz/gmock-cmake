# /FindGMOCK.cmake
#
# This CMake script will search for or add an external project target
# for both Google Test and Google Mock. It sets the following variables:
#
# GMOCK_FOUND: Whether Google Test and Mock were found
# GTEST_INCLUDE_DIR : Include directory containing gtest/gtest.h
# GMOCK_INCLUDE_DIR : Include directory containing gmock/gmock.h
# GTEST_LIBRARY : Linker line for the Google Test library
# GTEST_MAIN_LIBRARY : Linker line for the Google Test main () library.
#                      You should only link with this library if you do not
#                      need to overload the testing environment with a
#                      custom one.
# GMOCK_LIBRARY : Linker line for the Google Mock library
# GMOCK_MAIN_LIBRARY : Linker line for the Google Mock main () library.
#                      You should only link with this library if you do not
#                      need to overload the testing environment with a
#                      custom one.
# GTEST_BOTH_LIBRARIES : Convenience variable containing the result of both
#                        ${GTEST_LIBRARY} and ${GMOCK_LIBRARY} as well as any
#                        pthread libraries required for Google Test's operation.
# GTEST_LIBRARY_DIRS : The directory that contains the Google Test libraries.
# GTEST_COMPILE_DEFINITIONS : Compile definitions that must be set when
#                             including Google Test.
#
# There is some trickiness that comes with setting up both Google Test and
# Google Mock. Different vendors tend to ship it in different ways.
#
# 0. A parent directory could have build Google Test and Google Mock,
#    and have provided us with the relevant paths in the form of
#    the following options:
#
#    GTEST_INCLUDE_DIR
#    GMOCK_INCLUDE_DIR
#    GTEST_LIBRARY_LOCATION
#    GMOCK_LIBRARY_LOCATION
#    GTEST_MAIN_LIBRARY_LOCATION
#    GMOCK_MAIN_LIBRARY_LOCATION
#
# 1. Google Test and Google Mock are shipped as a pre-built library
#    in which case we can use both and set the include directories.
# 2. Google Mock is shipped as a pre-built library, but Google Test
#    is shipped in source-form, in which case the latter must be built
#    from source and the former linked in.
# 3. Only Google Mock is shipped in source-form, including a distribution
#    of Google Test. Both must be built and linked in.
# 4. It may not be shipped or available at all, in which case, we must
#    add an external project rule to download, configure and build it
#    at build time. We then import the resultant library.
#
#    We can do this by either:
#    a) Building using git
#    b) Downloading a released version.
#
# The C++ One Definition Rule requires that all symbols have the same
# definition at link time. If they do not, then multiple copies of the
# symbols will be created and this will lead to undefined and unwanted
# behavior. If you plan to alter the definitions provided in the
# Google Mock or Google Test header files by changing preprocessor
# definitions, then you almost certainly do not want to link with a
# pre-built system Google Mock or Google Test which would have been
# built with different definitions. As such, you should consider
# changing the following option:
#
# GTEST_PREFER_SOURCE_BUILD : Whether or not to prefer a source build of
#                             Google Test.
# GMOCK_PREFER_SOURCE_BUILD : Whether or not to prefer a source build of
#                             Google Mock.
# GMOCK_ALWAYS_DOWNLOAD_SOURCES : Whether to always download the Google Mock
#                                 sources if building Google Mock, as opposed
#                                 to using the sources shipped on the system.
# GMOCK_DOWNLOAD_VERSION : If downloading Google Mock, which version to download
#                          (defaults to GIT)
# GMOCK_FORCE_UPDATE : If downloading from GIT, whether or not to run the
#                      update step, which is not run by default.
#
# See /LICENCE.md for Copyright information

include ("cmake/cmake-include-guard/IncludeGuard")

cmake_include_guard (SET_MODULE_PATH)

include (CheckForGoogleMockCompilerFlags)
include (CMakeParseArguments)
include (FindPackageHandleStandardArgs)
include (FindPackageMessage)
include (GoogleMockLibraryUtils)

find_package (Threads REQUIRED)
find_package (Git)

option (GTEST_PREFER_SOURCE_BUILD
        OFF)
option (GMOCK_PREFER_SOURCE_BUILD
        OFF)
option (GMOCK_ALWAYS_DOWNLOAD_SOURCES
        OFF)

if (GMOCK_ALWAYS_DOWNLOAD_SOURCES AND GIT_FOUND)

    set (GTEST_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
    set (GMOCK_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)

else ()

    set (GTEST_PREFER_SOURCE_BUILD OFF CACHE BOOL "" FORCE)
    set (GMOCK_PREFER_SOURCE_BUILD OFF CACHE BOOL "" FORCE)

endif ()

# A wrapper around psq_import_external_project. This will cause
# CXXFLAGS to be set as desired, but only when importing the external project.
function (_gmock_add_external_project_with_our_cflags PROJECT_NAME)

    set (ADD_WITH_FLAGS_MULTIVAR_ARGS OPTIONS TARGETS INCLUDE_DIRS NAMESPACES)

    cmake_parse_arguments (ADD_WITH_FLAGS
                           ""
                           ""
                           "${ADD_WITH_FLAGS_MULTIVAR_ARGS}"
                           ${ARGN})

    # Forward GMOCK_CXX_FLAGS. We don't want warnings for uninitialized
    # private fields, etc.
    list (APPEND ADD_WITH_FLAGS_OPTIONS
          CMAKE_ARGS
          -Dgtest_force_shared_crt=ON
          "-DCMAKE_CXX_FLAGS=\"${CMAKE_CXX_FLAGS} ${GMOCK_CXX_FLAGS}\"")

    psq_import_external_project (${PROJECT_NAME} gmock-exports
                                 OPTIONS
                                 ${ADD_WITH_FLAGS_OPTIONS}
                                 TARGETS
                                 ${ADD_WITH_FLAGS_TARGETS}
                                 INCLUDE_DIRS
                                 ${ADD_WITH_FLAGS_INCLUDE_DIRS}
                                 NAMESPACES
                                 ${ADD_WITH_FLAGS_NAMESPACES}
                                 GENERATE_EXPORTS)

endfunction ()

# Converts a library name to uppercase and appends LIBRARY
function (_gmock_library_var_from_library_name LIBRARY_NAME
                                               LIBRARY_VARIABLE_RETURN)

    string (TOUPPER "${LIBRARY_NAME}" LIBRARY_NAME_UPPER)
    set (${LIBRARY_VARIABLE_RETURN} ${LIBRARY_NAME_UPPER}_LIBRARY PARENT_SCOPE)

endfunction ()

# Finds the very first component of an include path, uppercase it and
# appends _INCLUDE_DIR
function (_gmock_include_dir_var_from_include_path INCLUDE_PATH
                                                   INCLUDE_DIR_VARIABLE_RETURN)

    get_filename_component (FIRST_DIRECTORY "${INCLUDE_PATH}" PATH)
    string (TOUPPER "${FIRST_DIRECTORY}" INCLUDE_DIR_UPPER)
    set (${INCLUDE_DIR_VARIABLE_RETURN}
         ${INCLUDE_DIR_UPPER}_INCLUDE_DIR
         PARENT_SCOPE)

endfunction ()

macro (_gmock_fail_find_and_import_if_unset VARIABLE)

    if (NOT ${VARIABLE})

        # Make sure to unset all cache entries
        foreach (LIBRARY_NAME ${FIND_AND_IMPORT_LIBRARIES})

            _gmock_library_var_from_library_name (${LIBRARY_NAME}
                                                  LIBRARY_VARIABLE)
            unset (${LIBRARY_VARIABLE}_PATH CACHE)

        endforeach ()

        foreach (INCLUDE_PATH ${FIND_AND_IMPORT_INCLUDE_PATHS})

            _gmock_include_dir_var_from_include_path ("${INCLUDE_PATH}"
                                                      INCLUDE_DIR_VARIABLE)
            unset (${INCLUDE_DIR_VARIABLE}_PATH CACHE)

        endforeach ()

        set (${SUCCESS_RETURN} FALSE PARENT_SCOPE)
        return ()

    endif ()

endmacro ()

# Finds libraries and include directories as installed on the system and
# creates import targets for all of them (and puts them into the cache
# as (LIBRARY_UPPERCASE|INCLUDE_DIR_UPPERCASE)_(LIBRARY|INCLUDE_DIR))
#
# SUCCESS_RETURN will be true if the import operation was successful.
#
# For example, specifying gtest in LIBRARIES and gtest/gtest.h in
# INCLUDE_PATHS will insert GTEST_LIBRARY and GTEST_LIBRARY_LOCATION into
# the cache as well as GTEST_INCLUDE_DIR
function (_gmock_find_and_import_from_system SUCCESS_RETURN)

    set (FIND_AND_IMPORT_FROM_SYSTEM_MULTIVAR_ARGS LIBRARIES INCLUDE_PATHS)
    cmake_parse_arguments (FIND_AND_IMPORT
                           ""
                           ""
                           "${FIND_AND_IMPORT_FROM_SYSTEM_MULTIVAR_ARGS}"
                           ${ARGN})

    # Phase 1 just finds libraries and include directories. If any are not
    # found then we bail out
    foreach (LIBRARY_NAME ${FIND_AND_IMPORT_LIBRARIES})

        _gmock_library_var_from_library_name (${LIBRARY_NAME} LIBRARY_VARIABLE)
        find_library (${LIBRARY_VARIABLE}_PATH ${LIBRARY_NAME})
        _gmock_fail_find_and_import_if_unset (${LIBRARY_VARIABLE}_PATH)

    endforeach ()

    foreach (INCLUDE_PATH ${FIND_AND_IMPORT_INCLUDE_PATHS})

        _gmock_include_dir_var_from_include_path ("${INCLUDE_PATH}"
                                                  INCLUDE_DIR_VARIABLE)
        find_path (${INCLUDE_DIR_VARIABLE}_PATH "${INCLUDE_PATH}")
        _gmock_fail_find_and_import_if_unset (${INCLUDE_DIR_VARIABLE}_PATH)

    endforeach ()

    # Phase 2 looks through all the libraries and include directories again,
    # assumes that ${LIBRARY_VARIABLE}_PATH / ${INCLUDE_DIR_VARIABLE}_PATH
    # have been set and imports those libraries, making them available in
    # the cache
    foreach (LIBRARY_NAME ${FIND_AND_IMPORT_LIBRARIES})

        if (CMAKE_SYSTEM_NAME STREQUAL "Windows"
            AND NOT GTEST_FORCE_FIND_STATIC)

            # On Windows we can't link directly to the library, since building
            # as a static library is not supported. Link to the basename of
            # the library and make it the user's responsibility to place the
            # library in the correct path by importing it
            _gmock_library_var_from_library_name (${LIBRARY_NAME}
                                                  LIBRARY_VARIABLE)
            set (${LIBRARY_VARIABLE} ${LIBRARY_NAME} PARENT_SCOPE)

        else ()

            _gmock_library_var_from_library_name (${LIBRARY_NAME}
                                                  LIBRARY_VARIABLE)
            psq_import_utils_import_library (${LIBRARY_VARIABLE}
                                             ${LIBRARY_NAME}
                                             STATIC
                                             "${${LIBRARY_VARIABLE}_PATH}")
            unset (${LIBRARY_VARIABLE}_PATH CACHE)

        endif ()

    endforeach ()

    foreach (INCLUDE_PATH ${FIND_AND_IMPORT_INCLUDE_PATHS})

        _gmock_include_dir_var_from_include_path ("${INCLUDE_PATH}"
                                                  INCLUDE_DIR_VARIABLE)
        set (${INCLUDE_DIR_VARIABLE} "${${INCLUDE_DIR_VARIABLE}_PATH}"
             CACHE FILEPATH "" FORCE)
        unset (${INCLUDE_DIR_VARIABLE}_PATH CACHE)

    endforeach ()

    set (${SUCCESS_RETURN} TRUE PARENT_SCOPE)

endfunction ()

# Removes INCLUDE_BASE from INCLUDE_DIR to find an installation prefix
function (_gmock_find_prefix_from_base INCLUDE_BASE INCLUDE_DIR PREFIX_VAR)

    string (LENGTH ${INCLUDE_BASE} INCLUDE_BASE_LENGTH)
    string (LENGTH "${INCLUDE_DIR}" INCLUDE_DIR_LENGTH)

    math (EXPR
          INCLUDE_PREFIX_LENGTH
          "${INCLUDE_DIR_LENGTH} - ${INCLUDE_BASE_LENGTH}")
    string (SUBSTRING
            "${INCLUDE_DIR}"
            0
            ${INCLUDE_PREFIX_LENGTH}
            INCLUDE_PREFIX)

    set (${PREFIX_VAR} ${INCLUDE_PREFIX} PARENT_SCOPE)

endfunction ()

# Finds corresponding installed source directories for an include path.
#
# For example, if gtest/gtest.h is passed, then this function will find
# ${PREFIX}/src/gtest and store the result in GTEST_SRC_DIR
function (_gmock_find_src_dirs_from_include_paths)

    set (FIND_SRC_DIRS_MULTIVAR_OPTIONS INCLUDE_PATHS)
    cmake_parse_arguments (FIND_SRC_DIRS
                           ""
                           ""
                           "${FIND_SRC_DIRS_MULTIVAR_OPTIONS}"
                           ${ARGN})

    foreach (INCLUDE_PATH ${FIND_SRC_DIRS_INCLUDE_PATHS})

        get_filename_component (FIRST_DIRECTORY "${INCLUDE_PATH}" PATH)
        string (TOUPPER "${FIRST_DIRECTORY}" PREFIX_UPPER)

        find_path (${PREFIX_UPPER}_INCLUDE_DIR_CACHE "${INCLUDE_PATH}")

        if (${PREFIX_UPPER}_INCLUDE_DIR_CACHE)

            _gmock_find_prefix_from_base ("include/"
                                          ${${PREFIX_UPPER}_INCLUDE_DIR_CACHE}
                                          ${PREFIX_UPPER}_INCLUDE_PREFIX)

            set (SRC_DIR "${${PREFIX_UPPER}_INCLUDE_PREFIX}/src")
            find_path (${PREFIX_UPPER}_SRC_DIR_CACHE
                       CMakeLists.txt
                       PATHS
                       "${SRC_DIR}/${FIRST_DIRECTORY}"
                       NO_DEFAULT_PATH)

            if (${PREFIX_UPPER}_SRC_DIR_CACHE)

                set (${PREFIX_UPPER}_SRC_DIR
                     ${${PREFIX_UPPER}_SRC_DIR_CACHE}
                     PARENT_SCOPE)
                unset (${PREFIX_UPPER}_SRC_DIR_CACHE CACHE)

            endif ()

        endif ()

        unset (${PREFIX_UPPER}_INCLUDE_DIR_CACHE CACHE)

    endforeach ()

endfunction ()

function (_gmock_set_found FOUND_WHERE)

    set (GMOCK_SET_FOUND_OPTION_ARGS EXTERNALLY_OVERRIDDEN)
    cmake_parse_arguments (GMOCK_SET_FOUND
                           "${GMOCK_SET_FOUND_OPTION_ARGS}"
                           ""
                           ""
                           ${ARGN})

    if (NOT GMOCK_SET_FOUND_EXTERNALLY_OVERRIDDEN)

        set_property (GLOBAL PROPERTY _GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT
                      ON)

    endif ()

    set (GMOCK_FOUND ON PARENT_SCOPE)
    set (GMOCK_FOUND_WHERE "${FOUND_WHERE}" PARENT_SCOPE)

endfunction ()

# Situation 0. Google Test and Google Mock were provided by the user. Ignore
# any cache versions of these if we're actually just inside the same project
# (and reconfiguring it as such)
get_property (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT
              GLOBAL PROPERTY _GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

if (NOT _GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

    if (GTEST_INCLUDE_DIR AND
        GMOCK_INCLUDE_DIR AND
        GTEST_LIBRARY_LOCATION AND
        GMOCK_LIBRARY_LOCATION AND
        GTEST_MAIN_LIBRARY_LOCATION AND
        GMOCK_MAIN_LIBRARY_LOCATION)

        if (CMAKE_SYSTEM_NAME STREQUAL "Windows"
            AND NOT GTEST_FORCE_FIND_STATIC)

            set (GTEST_LIBRARY "gtest")
            set (GMOCK_LIBRARY "gmock")
            set (GTEST_MAIN_LIBRARY "gtest_main")
            set (GMOCK_MAIN_LIBRARY "gmock_main")

            set (LIBRARY_LOCATIONS
                 "${GTEST_LIBRARY_LOCATION} ${GMOCK_LIBRARY_LOCATION}")

            _gmock_set_found ("-- loading as DLLs, make sure they are in PATH")

            get_filename_component (GTEST_LIBRARY_DIRECTORY
                                    "${GTEST_LIBRARY_LOCATION}"
                                    DIRECTORY)
            get_filename_component (GMOCK_LIBRARY_DIRECTORY
                                    "${GMOCK_LIBRARY_LOCATION}"
                                    DIRECTORY)
            get_filename_component (GTEST_MAIN_LIBRARY_DIRECTORY
                                    "${GTEST_MAIN_LIBRARY_LOCATION}"
                                    DIRECTORY)
            get_filename_component (GMOCK_MAIN_LIBRARY_DIRECTORY
                                    "${GMOCK_MAIN_LIBRARY_LOCATION}"
                                    DIRECTORY)

            set (GTEST_LIBRARY_DIRS
                 "${GTEST_LIBRARY_DIRECTORY}"
                 "${GMOCK_LIBRARY_DIRECTORY}"
                 "${GTEST_MAIN_LIBRARY_DIRECTORY}"
                 "${GMOCK_MAIN_LIBRARY_DIRECTORY}")

        else ()

            psq_import_utils_import_library (GTEST_LIBRARY gtest STATIC
                                             "${GTEST_LIBRARY_LOCATION}")
            psq_import_utils_import_library (GMOCK_LIBRARY gmock STATIC
                                             "${GMOCK_LIBRARY_LOCATION}")
            psq_import_utils_import_library (GTEST_MAIN_LIBRARY
                                             gtest_main STATIC
                                             "${GTEST_MAIN_LIBRARY_LOCATION}")
            psq_import_utils_import_library (GMOCK_MAIN_LIBRARY
                                             gmock_main STATIC
                                             "${GMOCK_MAIN_LIBRARY_LOCATION}")

            set (LIBRARY_LOCATIONS
                 "${GTEST_LIBRARY_LOCATION} ${GMOCK_LIBRARY_LOCATION}")

            _gmock_set_found ("-- overridden by ${LIBRARY_LOCATIONS}"
                              EXTERNALLY_OVERRIDDEN)

        endif ()

    endif (GTEST_INCLUDE_DIR AND
           GMOCK_INCLUDE_DIR AND
           GTEST_LIBRARY_LOCATION AND
           GMOCK_LIBRARY_LOCATION AND
           GTEST_MAIN_LIBRARY_LOCATION AND
           GMOCK_MAIN_LIBRARY_LOCATION)

endif ()

# Situation 1. Google Test and Google Mock are shipped in library form.
# Use the libraries unless there we've been asked not to.
if (NOT GMOCK_FOUND AND
    NOT GMOCK_PREFER_SOURCE_BUILD AND
    NOT GTEST_PREFER_SOURCE_BUILD)

    # Find both gtest and google-mock in library form first
    _gmock_find_and_import_from_system (SUCCESS
                                        LIBRARIES
                                        gtest gtest_main
                                        gmock gmock_main
                                        INCLUDE_PATHS
                                        "gtest/gtest.h"
                                        "gmock/gmock.h")


    if (SUCCESS)

        if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
            set (GTEST_COMPILE_DEFINITIONS
                 "-DGTEST_LINKED_AS_SHARED_LIBRARY=1")
        endif ()
        set (GMOCK_SYSTEM_PATHS
             "${GTEST_LIBRARY_LOCATION} ${GMOCK_LIBRARY_LOCATION}")
        _gmock_set_found ("-- in system paths ${GMOCK_SYSTEM_PATHS}")

    endif ()

endif (NOT GMOCK_FOUND AND
       NOT GMOCK_PREFER_SOURCE_BUILD AND
       NOT GTEST_PREFER_SOURCE_BUILD)

# Situation 2. Google Mock was not shipped in source form, but Google
# Test was, and it is acceptable to use Google Mock in library form.
if (NOT GMOCK_FOUND AND NOT GMOCK_PREFER_SOURCE_BUILD)

    # Find Google Test source directory
    _gmock_find_src_dirs_from_include_paths (INCLUDE_PATHS "gtest/gtest.h")

    if (GTEST_SRC_DIR)

        # We have a source dir. Import Google Mock from the system
        # and then use the source dir to build Google Test.
        _gmock_find_and_import_from_system (SUCCESS
                                            LIBRARIES
                                            gmock gmock_main
                                            INCLUDE_PATHS
                                            "gtest/gtest.h"
                                            "gmock/gmock.h")

        if (SUCCESS)

            _gmock_add_external_project_with_our_cflags (GoogleMock
                                                         gtest-exports
                                                         OPTIONS
                                                         URL "${GTEST_SRC_DIR}"
                                                         TARGETS
                                                         GTEST_LIBRARY
                                                         gtest
                                                         GTEST_MAIN_LIBRARY
                                                         gtest_main)

            if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
                set (GTEST_COMPILE_DEFINITIONS
                     "-DGTEST_LINKED_AS_SHARED_LIBRARY=1")
            endif ()

            set (GMOCK_FIND_DETAILS
                 "-- in system path ${GMOCK_LIBRARY_LOCATION} and "
                 "building from ${GTEST_SRC_DIR}")
            string (REPLACE ";" "" GMOCK_FIND_DETAILS "${GMOCK_FIND_DETAILS}")
            _gmock_set_found ("${GMOCK_FIND_DETAILS}")

        endif ()

    endif ()

endif ()

# Situation 3. Either we don't want to use the library forms, or
# Google Test or Google Mock wasn't shipped in library form.
# Try to see if Google Mock was shipped in source form and build
# both libraries.
if (NOT GMOCK_FOUND AND NOT GMOCK_ALWAYS_DOWNLOAD_SOURCES)

    # Find Google Test and Google Mock source directories
    _gmock_find_src_dirs_from_include_paths (INCLUDE_PATHS
                                             "gtest/gtest.h"
                                             "gmock/gmock.h")

    if (GMOCK_SRC_DIR AND GTEST_SRC_DIR)

        # Because gmock tries to reference gtest on a relative path
        # to itself, copy the entire build-tree into a subdirectory
        set (GMOCK_TREE "${CMAKE_CURRENT_BINARY_DIR}/GoogleMock/tree")
        file (COPY "${GMOCK_SRC_DIR}" DESTINATION ${GMOCK_TREE}
              NO_SOURCE_PERMISSIONS)
        file (COPY "${GTEST_SRC_DIR}" DESTINATION ${GMOCK_TREE}
              NO_SOURCE_PERMISSIONS)

        _gmock_find_and_import_from_system (SUCCESS
                                            INCLUDE_PATHS
                                            "gtest/gtest.h"
                                            "gmock/gmock.h")

        if (SUCCESS)

            _gmock_add_external_project_with_our_cflags (GoogleMock
                                                         gmock-exports
                                                         OPTIONS
                                                         SOURCE_DIR
                                                         "${GMOCK_TREE}/gmock"
                                                         TARGETS
                                                         GTEST_LIBRARY
                                                         gtest
                                                         GMOCK_LIBRARY
                                                         gmock
                                                         GTEST_MAIN_LIBRARY
                                                         gtest_main
                                                         GMOCK_MAIN_LIBRARY
                                                         gmock_main)

            _gmock_set_found ("-- building from ${GTEST_SRC_DIR}")

        endif ()

    endif ()

endif ()

# Situation 4. Neither was shipped in source form.
# Set up an external project, download it and build it there.
if (NOT GMOCK_FOUND)

    set (GMOCK_DOWNLOAD_VERSION "GIT" CACHE STRING
         "Version of Google Mock to download. Allowable: GIT, 1.7.0")
    option (GMOCK_FORCE_UPDATE
            "Force updates to Google Mock. Causes update on every build"
            OFF)

    set (GMOCK_DOWNLOAD_OPTIONS "")
    if (GMOCK_DOWNLOAD_VERSION STREQUAL "GIT" AND GIT_FOUND)

        # For Windows, we need to specify the git commands here,
        # externalproject will attempt to check out submodules,
        # which fails when drive letter substitutions are in place
        # on Windows.
        #
        # Also on Windows, we are not able to add an update
        # command, since git pull does not understand UNC
        # paths.
        set (GMOCK_GIT_URL "git://github.com/google/googletest")

        if ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")

            if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/GoogleMock")

                set (GMOCK_DOWNLOAD_OPTIONS
                     DOWNLOAD_COMMAND "${GIT_EXECUTABLE}"
                                      clone
                                      "${GMOCK_GIT_URL}"
                                      GoogleMock)

            endif ()

        else ()

            set (GMOCK_DOWNLOAD_OPTIONS
                 GIT_REPOSITORY "${GMOCK_GIT_URL}")

        endif ()

        set (GMOCK_INCLUDE_DIR_OPTIONS
             GTEST_INCLUDE_DIR
             "googletest/include"
             GMOCK_INCLUDE_DIR
             "googlemock/include")

        if (NOT GMOCK_FORCE_UPDATE)

            if (CMAKE_VERSION VERSION_LESS "3.1.0")

                set (GMOCK_DOWNLOAD_OPTIONS
                     ${GMOCK_DOWNLOAD_OPTIONS}
                     UPDATE_COMMAND echo "Skipping Update")

            else ()

                set (GMOCK_DOWNLOAD_OPTIONS
                     ${GMOCK_DOWNLOAD_OPTIONS}
                     UPDATE_DISCONNECTED 1)

            endif ()

        endif ()

    else ()

        set (GMOCK_ACCEPTABLE_VERSIONS "1.7.0")
        set (GMOCK_VERSION_IS_ACCEPTABLE FALSE)

        foreach (VERSION ${GMOCK_ACCEPTABLE_VERSIONS})

            if (VERSION STREQUAL GMOCK_DOWNLOAD_VERSION)

                set (GMOCK_VERSION_IS_ACCEPTABLE TRUE)

            endif ()

        endforeach ()

        if (NOT GMOCK_VERSION_IS_ACCEPTABLE)

            message (FATAL_ERROR
                     "Google Mock version number: ${GMOCK_DOWNLOAD_VERSION} "
                     "isn't valid. Valid values are: "
                     "${GMOCK_ACCEPTABLE_VERSIONS}")

        endif ()

        set (GMOCK_URL_BASE
             "http://googlemock.googlecode.com/files/gmock-")
        set (GMOCK_DOWNLOAD_OPTIONS
             URL ${GMOCK_URL_BASE}${GMOCK_DOWNLOAD_VERSION}.zip)
        set (GMOCK_INCLUDE_DIR_OPTIONS
             GTEST_INCLUDE_DIR
             "gtest/include"
             GMOCK_INCLUDE_DIR
             "include")

    endif ()



    _gmock_add_external_project_with_our_cflags (GoogleMock gmock-exports
                                                 OPTIONS
                                                 ${GMOCK_DOWNLOAD_OPTIONS}
                                                 TARGETS
                                                 GTEST_LIBRARY gtest
                                                 GMOCK_LIBRARY gmock
                                                 GTEST_MAIN_LIBRARY gtest_main
                                                 GMOCK_MAIN_LIBRARY gmock_main
                                                 INCLUDE_DIRS
                                                 ${GMOCK_INCLUDE_DIR_OPTIONS}
                                                 NAMESPACES GTEST GMOCK)

    _gmock_set_found ("-- downloading version ${GMOCK_DOWNLOAD_VERSION}")

endif ()

function (_gmock_override_compile_flags TARGET)

    if (TARGET ${TARGET})

        set_property (TARGET ${TARGET}
                      APPEND_STRING
                      PROPERTY COMPILE_FLAGS
                      " ${GMOCK_CXX_FLAGS}")

    endif ()

endfunction ()

if (GMOCK_FOUND)

    # Set the library names as variables for other binaries to use.
    set (GTEST_BOTH_LIBRARIES
         ${CMAKE_THREAD_LIBS_INIT}
         ${GTEST_LIBRARY}
         ${GTEST_MAIN_LIBRARY})

    # Unconditionally override compile flags. These will always
    # be on targets, so it will always be successful.
    _gmock_override_compile_flags (${GTEST_LIBRARY})
    _gmock_override_compile_flags (${GTEST_MAIN_LIBRARY})
    _gmock_override_compile_flags (${GMOCK_LIBRARY})
    _gmock_override_compile_flags (${GMOCK_MAIN_LIBRARY})

endif ()

set (GMOCK_FOUND ${GMOCK_FOUND} CACHE BOOL "" FORCE)
find_package_handle_standard_args (GMOCK
                                   REQUIRED_VARS
                                   GMOCK_FOUND
                                   GTEST_LIBRARY
                                   GTEST_MAIN_LIBRARY
                                   GMOCK_LIBRARY
                                   GMOCK_MAIN_LIBRARY
                                   GTEST_INCLUDE_DIR
                                   GMOCK_INCLUDE_DIR)
find_package_message (GMOCK
                      "Google Test and Google Mock Found ${GMOCK_FOUND_WHERE}"
                      "[${GTEST_LIBRARY}][${GMOCK_LIBRARY}]")

set (GMOCK_FOUND_VALUE ${GMOCK_FOUND})
unset (GMOCK_FOUND CACHE)
set (GMOCK_FOUND ${GMOCK_FOUND_VALUE})
