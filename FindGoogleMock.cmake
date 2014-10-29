# FindGoogleMock.cmake
#
# This CMake script will search for or add an external project target
# for both Google Test and Google Mock. It sets the following variables:
#
# GOOGLE_MOCK_FOUND: Whether Google Test and Mock were found
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
#    in which case we can use both and set the include dirs.
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
#    a) Building using SVN
#    b) Downloading a released version.
#
# The C++ One Definition Rule requires that all symbols have the same
# definition at link time. If they do not, then multiple copies of the
# symbols will be created and this will lead to undefined and unwanted
# behaviour. If you plan to alter the definitions provided in the
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
#                          (defaults to SVN)
# GMOCK_FORCE_UPDATE : If downloading from SVN, whether or not to run the 
#                      update step, which is not run by default.

include (CheckForGoogleMockCompilerFlags)
include (CMakeParseArguments)
include (FindPackageHandleStandardArgs)
include (FindPackageMessage)
include (GoogleMockLibraryUtils)

find_package (Threads REQUIRED)

option (GTEST_PREFER_SOURCE_BUILD
        "Whether or not to prefer a source build of Google Test." OFF)
option (GMOCK_PREFER_SOURCE_BUILD
        "Whether or not to prefer a source build of Google Mock." OFF)
option (GMOCK_ALWAYS_DOWNLOAD_SOURCES
        "Whether or not to always download the sources for Google Mock." OFF)

if (GMOCK_ALWAYS_DOWNLOAD_SOURCES)

  set (GTEST_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
  set (GMOCK_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)

endif (GMOCK_ALWAYS_DOWNLOAD_SOURCES)

# Already found, return
if (GOOGLE_MOCK_FOUND)

    return ()

endif (GOOGLE_MOCK_FOUND)

# A wrapper around polysquare_import_external_project. This will cause
# CXXFLAGS to be set as desired, but only when importing the external project.
function (_add_external_project_with_gmock_cflags PROJECT_NAME EXPORTS)

    set (ADD_WITH_FLAGS_MULTIVAR_ARGS OPTIONS TARGETS INCLUDE_DIRS NAMESPACES)

    cmake_parse_arguments (ADD_WITH_FLAGS
                           ""
                           ""
                           "${ADD_WITH_FLAGS_MULTIVAR_ARGS}"
                           ${ARGN})

    # Backup CMAKE_CXX_FLAGS, modify it and forward it. We don't want warnings
    # for unintialized private fields, etc.
    set (CMAKE_CXX_FLAGS_BACKUP ${CMAKE_CXX_FLAGS})
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${GMOCK_CXX_FLAGS}")

    polysquare_import_external_project (${PROJECT_NAME} gmock-exports
                                        OPTIONS
                                        ${ADD_WITH_FLAGS_OPTIONS}
                                        TARGETS
                                        ${ADD_WITH_FLAGS_TARGETS}
                                        INCLUDE_DIRS
                                        ${ADD_WITH_FLAGS_INCLUDE_DIRS}
                                        NAMESPACES
                                        ${ADD_WITH_FLAGS_NAMESPACES}
                                        GENERATE_EXPORTS)

    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_BACKUP}")

endfunction (_add_external_project_with_gmock_cflags)

# Converts a library name to uppercase and appends LIBRARY
function (_gmock_library_var_from_library_name LIBRARY_NAME
                                               LIBRARY_VARIABLE_RETURN)

    string (TOUPPER "${LIBRARY_NAME}" LIBRARY_NAME_UPPER)
    set (${LIBRARY_VARIABLE_RETURN} ${LIBRARY_NAME_UPPER}_LIBRARY PARENT_SCOPE)

endfunction (_gmock_library_var_from_library_name)

# Finds the very first component of an include path, uppercases it and
# appends _INCLUDE_DIR
function (_gmock_include_dir_var_from_include_path INCLUDE_PATH
                                                   INCLUDE_DIR_VARIABLE_RETURN)

    get_filename_component (FIRST_DIRECTORY "${INCLUDE_PATH}" PATH)
    string (TOUPPER "${FIRST_DIRECTORY}" INCLUDE_DIR_UPPER)
    set (${INCLUDE_DIR_VARIABLE_RETURN}
         ${INCLUDE_DIR_UPPER}_INCLUDE_DIR
         PARENT_SCOPE)

endfunction (_gmock_include_dir_var_from_include_path)

macro (_gmock_fail_find_and_import_if_unset VARIABLE)

    if (NOT ${VARIABLE})

        # Make sure to unset all cache entries
        foreach (LIBRARY_NAME ${FIND_AND_IMPORT_LIBRARIES})

            _gmock_library_var_from_library_name (${LIBRARY_NAME}
                                                  LIBRARY_VARIABLE)
            unset (${LIBRARY_VARIABLE}_PATH CACHE)

        endforeach ()

        foreach (INCLUDE_PATH ${FIND_AND_IMPORT_INCLUDE_PATHS})

            _gmock_include_dir_var_from_include_path (${INCLUDE_PATH}
                                                      INCLUDE_DIR_VARIABLE)
            unset (${INCLUDE_DIR_VARIABLE}_PATH CACHE)

        endforeach ()

        set (${SUCCESS_RETURN} FALSE PARENT_SCOPE)
        return ()

    endif (NOT ${VARIABLE})

endmacro (_gmock_fail_find_and_import_if_unset)

# Finds libraries and include dirs as installed on the system and
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

    # Phase 1 just finds libraries and include dirs. If any are not
    # found then we bail out
    foreach (LIBRARY_NAME ${FIND_AND_IMPORT_LIBRARIES})

        _gmock_library_var_from_library_name (${LIBRARY_NAME} LIBRARY_VARIABLE)
        find_library (${LIBRARY_VARIABLE}_PATH ${LIBRARY_NAME})
        _gmock_fail_find_and_import_if_unset (${LIBRARY_VARIABLE}_PATH)

    endforeach ()

    foreach (INCLUDE_PATH ${FIND_AND_IMPORT_INCLUDE_PATHS})

        _gmock_include_dir_var_from_include_path (${INCLUDE_PATH}
                                                  INCLUDE_DIR_VARIABLE)
        find_path (${INCLUDE_DIR_VARIABLE}_PATH ${INCLUDE_PATH})
        _gmock_fail_find_and_import_if_unset (${INCLUDE_DIR_VARIABLE}_PATH)

    endforeach ()

    # Phase 2 looks through all the libraries and include dirs again,
    # assumes that ${LIBRARY_VARIABLE}_PATH / ${INCLUDE_DIR_VARIABLE}_PATH
    # have been set and imports those libraries, making them available in
    # the cache
    foreach (LIBRARY_NAME ${FIND_AND_IMPORT_LIBRARIES})

        _gmock_library_var_from_library_name (${LIBRARY_NAME} LIBRARY_VARIABLE)
        polysquare_import_utils_import_library (${LIBRARY_VARIABLE}
                                                ${LIBRARY_NAME} STATIC
                                                ${${LIBRARY_VARIABLE}_PATH})
        unset (${LIBRARY_VARIABLE}_PATH CACHE)

    endforeach ()

    foreach (INCLUDE_PATH ${FIND_AND_IMPORT_INCLUDE_PATHS})

        _gmock_include_dir_var_from_include_path (${INCLUDE_PATH}
                                                  INCLUDE_DIR_VARIABLE)
        set (${INCLUDE_DIR_VARIABLE} ${${INCLUDE_DIR_VARIABLE}_PATH}
             CACHE FILEPATH "" FORCE)
        unset (${INCLUDE_DIR_VARIABLE}_PATH CACHE)

    endforeach ()

    set (${SUCCESS_RETURN} TRUE PARENT_SCOPE)

endfunction (_gmock_find_and_import_from_system)

# Removes INCLUDE_BASE from INCLUDE_DIR to find an installation prefix
function (_gmock_find_prefix_from_base INCLUDE_BASE INCLUDE_DIR PREFIX_VAR)

    string (LENGTH ${INCLUDE_BASE} INCLUDE_BASE_LENGTH)
    string (LENGTH ${INCLUDE_DIR} INCLUDE_DIR_LENGTH)

    math (EXPR
          INCLUDE_PREFIX_LENGTH
          "${INCLUDE_DIR_LENGTH} - ${INCLUDE_BASE_LENGTH}")
    string (SUBSTRING
            ${INCLUDE_DIR}
            0
            ${INCLUDE_PREFIX_LENGTH}
            INCLUDE_PREFIX)

    set (${PREFIX_VAR} ${INCLUDE_PREFIX} PARENT_SCOPE)

endfunction (_gmock_find_prefix_from_base)

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

        find_path (${PREFIX_UPPER}_INCLUDE_DIR_CACHE ${INCLUDE_PATH})

        if (${PREFIX_UPPER}_INCLUDE_DIR_CACHE)

            _gmock_find_prefix_from_base ("include/"
                                          ${${PREFIX_UPPER}_INCLUDE_DIR_CACHE}
                                          ${PREFIX_UPPER}_INCLUDE_PREFIX)

            find_path (${PREFIX_UPPER}_SRC_DIR_CACHE
                       CMakeLists.txt
                       PATHS
                       ${${PREFIX_UPPER}_INCLUDE_PREFIX}/src/${FIRST_DIRECTORY}
                       NO_DEFAULT_PATH)

            if (${PREFIX_UPPER}_SRC_DIR_CACHE)

                set (${PREFIX_UPPER}_SRC_DIR
                     ${${PREFIX_UPPER}_SRC_DIR_CACHE}
                     PARENT_SCOPE)
                unset (${PREFIX_UPPER}_SRC_DIR_CACHE CACHE)

            endif (${PREFIX_UPPER}_SRC_DIR_CACHE)

        endif (${PREFIX_UPPER}_INCLUDE_DIR_CACHE)

        unset (${PREFIX_UPPER}_INCLUDE_DIR_CACHE CACHE)

    endforeach ()

endfunction (_gmock_find_src_dirs_from_include_paths)

function (_gmock_set_found FOUND_WHERE)

    set (GMOCK_SET_FOUND_OPTION_ARGS EXTERNALLY_OVERRIDDEN)
    cmake_parse_arguments (GMOCK_SET_FOUND
                           "${GMOCK_SET_FOUND_OPTION_ARGS}" "" ""
                           ${ARGN})

    if (NOT GMOCK_SET_FOUND_EXTERNALLY_OVERRIDDEN)

        set (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT
             ON CACHE BOOL "" FORCE)
        mark_as_advanced (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

    endif (NOT GMOCK_SET_FOUND_EXTERNALLY_OVERRIDDEN)

    set (GMOCK_FOUND TRUE PARENT_SCOPE)
    set (GMOCK_FOUND_WHERE "${FOUND_WHERE}" PARENT_SCOPE)

endfunction (_gmock_set_found)

# Situation 0. Google Test and Google Mock were provided by the user. Ignore
# any cache versions of these if we're actually just inside the same project
# (and reconfiguring it as such)
if (NOT _GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

    if (GTEST_INCLUDE_DIR AND
        GMOCK_INCLUDE_DIR AND
        GTEST_LIBRARY_LOCATION AND
        GMOCK_LIBRARY_LOCATION AND
        GTEST_MAIN_LIBRARY_LOCATION AND
        GMOCK_MAIN_LIBRARY_LOCATION)

        polysquare_import_utils_import_library (GTEST_LIBRARY gtest STATIC
                                                ${GTEST_LIBRARY_LOCATION})
        polysquare_import_utils_import_library (GMOCK_LIBRARY gmock STATIC
                                                ${GMOCK_LIBRARY_LOCATION})
        polysquare_import_utils_import_library (GTEST_MAIN_LIBRARY
                                                gtest_main STATIC
                                                ${GTEST_MAIN_LIBRARY_LOCATION})
        polysquare_import_utils_import_library (GMOCK_MAIN_LIBRARY
                                                gmock_main STATIC
                                                ${GMOCK_MAIN_LIBRARY_LOCATION})

        set (LIBRARY_LOCATIONS
             "${GTEST_LIBRARY_LOCATION} ${GMOCK_LIBRARY_LOCATION}")
        _gmock_set_found ("-- overridden by ${LIBRARY_LOCATIONS}"
                          EXTERNALLY_OVERRIDDEN)

    endif (GTEST_INCLUDE_DIR AND
           GMOCK_INCLUDE_DIR AND
           GTEST_LIBRARY_LOCATION AND
           GMOCK_LIBRARY_LOCATION AND
           GTEST_MAIN_LIBRARY_LOCATION AND
           GMOCK_MAIN_LIBRARY_LOCATION)

endif (NOT _GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

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
                                            gtest/gtest.h
                                            gmock/gmock.h)


        if (SUCCESS)

            set (GMOCK_SYSTEM_PATHS
                 "${GTEST_LIBRARY_LOCATION} ${GMOCK_LIBRARY_LOCATION}")
            _gmock_set_found ("-- in system paths ${GMOCK_SYSTEM_PATHS}")

        endif (SUCCESS)

endif (NOT GMOCK_FOUND AND
       NOT GMOCK_PREFER_SOURCE_BUILD AND
       NOT GTEST_PREFER_SOURCE_BUILD)

# Situation 2. Google Mock was not shipped in source form, but Google
# Test was, and it is acceptable to use Google Mock in library form.
if (NOT GMOCK_FOUND AND NOT GMOCK_PREFER_SOURCE_BUILD)

    # Find Google Test source directory
    _gmock_find_src_dirs_from_include_paths (INCLUDE_PATHS gtest/gtest.h)

    if (GTEST_SRC_DIR)

        # We have a source dir. Import Google Mock from the system
        # and then use the source dir to build Google Test.
        _gmock_find_and_import_from_system (SUCCESS
                                            LIBRARIES
                                            gmock gmock_main
                                            INCLUDE_PATHS
                                            gtest/gtest.h
                                            gmock/gmock.h)

        if (SUCCESS)

            _add_external_project_with_gmock_cflags (GoogleMock
                                                     gtest-exports
                                                     OPTIONS
                                                     URL ${GTEST_SRC_DIR}
                                                     TARGETS
                                                     GTEST_LIBRARY
                                                     gtest
                                                     GTEST_MAIN_LIBRARY
                                                     gtest_main)

            set (GMOCK_FIND_DETAILS
                 "-- in system path ${GMOCK_LIBRARY_LOCATION} and "
                 "building from ${GTEST_SRC_DIR}")
            string (REPLACE ";" "" GMOCK_FIND_DETAILS "${GMOCK_FIND_DETAILS}")
            _gmock_set_found ("${GMOCK_FIND_DETAILS}")

        endif (SUCCESS)

    endif (GTEST_SRC_DIR)

endif (NOT GMOCK_FOUND AND NOT GMOCK_PREFER_SOURCE_BUILD)

# Situation 3. Either we don't want to use the library forms, or
# Google Test or Google Mock wasn't shipped in library form.
# Try to see if Google Mock was shipped in source form and build
# both libraries.
if (NOT GMOCK_FOUND AND NOT GMOCK_ALWAYS_DOWNLOAD_SOURCES)

    # Find Google Test and Google Mock source directories
    _gmock_find_src_dirs_from_include_paths (INCLUDE_PATHS
                                             gtest/gtest.h
                                             gmock/gmock.h)

    if (GMOCK_SRC_DIR AND GTEST_SRC_DIR)

        # Because gmock tries to reference gtest on a relative path
        # to itself, copy the entire build-tree into a subdirectory
        set (GMOCK_TREE ${CMAKE_CURRENT_BINARY_DIR}/GoogleMock/tree)
        file (COPY ${GMOCK_SRC_DIR} DESTINATION ${GMOCK_TREE}
              NO_SOURCE_PERMISSIONS)
        file (COPY ${GTEST_SRC_DIR} DESTINATION ${GMOCK_TREE}
              NO_SOURCE_PERMISSIONS)

        _gmock_find_and_import_from_system (SUCCESS
                                            INCLUDE_PATHS
                                            gtest/gtest.h
                                            gmock/gmock.h)

        if (SUCCESS)

            _add_external_project_with_gmock_cflags (GoogleMock
                                                     gmock-exports
                                                     OPTIONS
                                                     SOURCE_DIR
                                                     ${GMOCK_TREE}/gmock
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

        endif (SUCCESS)

    endif (GMOCK_SRC_DIR AND GTEST_SRC_DIR)

endif (NOT GMOCK_FOUND AND NOT GMOCK_ALWAYS_DOWNLOAD_SOURCES)

# Situation 4. Neither was shipped in source form.
# Set up an external project, download it and build it there.
if (NOT GMOCK_FOUND)

    set (GMOCK_DOWNLOAD_VERSION "SVN" CACHE STRING
         "Version of Google Mock to download. Allowable: SVN, 1.7.0")
    option (GMOCK_FORCE_UPDATE
            "Force updates to Google Mock. Causes update on every build"
            OFF)

    set (GMOCK_DOWNLOAD_OPTIONS "")
    if (GMOCK_DOWNLOAD_VERSION STREQUAL "SVN")

        set (GMOCK_SVN_URL "http://googlemock.googlecode.com/svn/trunk")
        set (GMOCK_DOWNLOAD_OPTIONS SVN_REPOSITORY ${GMOCK_SVN_URL})

        if (NOT GMOCK_FORCE_UPDATE)

            set (GMOCK_DOWNLOAD_OPTIONS
                 ${GMOCK_DOWNLOAD_OPTIONS}
                 UPDATE_COMMAND
                 "echo")

        endif (NOT GMOCK_FORCE_UPDATE)

    else (GMOCK_DOWNLOAD_VERSION STREQUAL "SVN")

        set (GMOCK_ACCEPTABLE_VERSIONS "1.7.0")
        set (GMOCK_VERSION_IS_ACCEPTABLE FALSE)

        foreach (VERSION ${GMOCK_ACCEPTABLE_VERSIONS})

            if (VERSION STREQUAL GMOCK_DOWNLOAD_VERSION)

                set (GMOCK_VERSION_IS_ACCEPTABLE TRUE)

            endif (VERSION STREQUAL GMOCK_DOWNLOAD_VERSION)

        endforeach ()

        if (NOT GMOCK_VERSION_IS_ACCEPTABLE)

            message (FATAL_ERROR
                     "Google Mock version number: ${GMOCK_DOWNLOAD_VERSION} "
                     "isn't valid. Valid values are: "
                     "${GMOCK_ACCEPTABLE_VERSIONS}")

        endif (NOT GMOCK_VERSION_IS_ACCEPTABLE)

        set (GMOCK_URL_BASE "http://googlemock.googlecode.com/files/gmock-")
        set (GMOCK_DOWNLOAD_OPTIONS
             URL ${GMOCK_URL_BASE}${GMOCK_DOWNLOAD_VERSION}.zip)

    endif (GMOCK_DOWNLOAD_VERSION STREQUAL "SVN")

    _add_external_project_with_gmock_cflags (GoogleMock gmock-exports
                                             OPTIONS
                                             ${GMOCK_DOWNLOAD_OPTIONS}
                                             TARGETS
                                             GTEST_LIBRARY gtest
                                             GMOCK_LIBRARY gmock
                                             GTEST_MAIN_LIBRARY gtest_main
                                             GMOCK_MAIN_LIBRARY gmock_main
                                             INCLUDE_DIRS
                                             GTEST_INCLUDE_DIR gtest/include
                                             GMOCK_INCLUDE_DIR include
                                             NAMESPACES GTEST GMOCK)

    _gmock_set_found ("-- downloading version ${GMOCK_DOWNLOAD_VERSION}")

endif (NOT GMOCK_FOUND)

function (_override_gmock_compile_flags TARGET)

    set_property (TARGET ${TARGET}
                  APPEND_STRING
                  PROPERTY COMPILE_FLAGS
                  " ${GMOCK_CXX_FLAGS}")

endfunction (_override_gmock_compile_flags)

if (GMOCK_FOUND)

    # Set the library names as variables for other binaries to use.
    set (GTEST_BOTH_LIBRARIES
         ${CMAKE_THREAD_LIBS_INIT}
         ${GTEST_LIBRARY}
         ${GTEST_MAIN_LIBRARY})

    # Unconditionally override compile flags. These will always
    # be on targets, so it will always be successful.
    _override_gmock_compile_flags (${GTEST_LIBRARY})
    _override_gmock_compile_flags (${GTEST_MAIN_LIBRARY})
    _override_gmock_compile_flags (${GMOCK_LIBRARY})
    _override_gmock_compile_flags (${GMOCK_MAIN_LIBRARY})

endif (GMOCK_FOUND)

find_package_handle_standard_args (GoogleMock
                                   REQUIRED_VARS
                                   GMOCK_FOUND
                                   GTEST_LIBRARY
                                   GTEST_MAIN_LIBRARY
                                   GMOCK_LIBRARY
                                   GMOCK_MAIN_LIBRARY
                                   GTEST_INCLUDE_DIR
                                   GMOCK_INCLUDE_DIR)
find_package_message (GoogleMock
                      "Google Test and Google Mock Found ${GMOCK_FOUND_WHERE}"
                      "[${GTEST_LIBRARY}][${GMOCK_LIBRARY}]")
