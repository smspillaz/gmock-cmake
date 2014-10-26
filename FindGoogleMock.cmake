# FindGoogleMock.cmake
#
# This CMake script will search for or add an external project target
# for both Google Test and Google Mock. It sets the following variables:
#
# GTEST_FOUND : Whether or not Google Test was available on the system.
# GMOCK_FOUND : Whether or not Google Mock was available on the system.
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
#    A parent should also provide the following variable, as a dependency
#    to add in order to ensure that the Google Test and Google Mock
#    libraries are available when this target is built.
#
#    GTEST_AND_GMOCK_DEPENDENCY
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

include (CheckCXXCompilerFlag)
include (CMakeParseArguments)
include (GoogleMockLibraryUtils)
include (CheckForGoogleMockCompilerFlags)

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
if (GTEST_FOUND AND GMOCK_FOUND)

    return ()

endif (GTEST_FOUND AND GMOCK_FOUND)

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

if (HAVE_GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD)

    set (GMOCK_CXX_FLAGS
         "${GMOCK_CXX_FLAGS} ${GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD_FLAG}")

endif (HAVE_GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD)

if (HAVE_GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD)

    set (GMOCK_CXX_FLAGS
         "${GMOCK_CXX_FLAGS} ${GMOCK_NO_ERROR_MISSING_FIELD_INITIALIZERS_FLAG}")

endif (HAVE_GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD)

if (HAVE_GMOCK_FORCE_CXX98_FLAG)

    set (GMOCK_CXX_FLAGS
         "${GMOCK_CXX_FLAGS} ${GMOCK_FORCE_CXX98_FLAG}")

endif (HAVE_GMOCK_FORCE_CXX98_FLAG)

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

        set (GTEST_FOUND 1)
        set (GMOCK_FOUND 1)

    endif (GTEST_INCLUDE_DIR AND
           GMOCK_INCLUDE_DIR AND
           GTEST_LIBRARY_LOCATION AND
           GMOCK_LIBRARY_LOCATION AND
           GTEST_MAIN_LIBRARY_LOCATION AND
           GMOCK_MAIN_LIBRARY_LOCATION)

endif (NOT _GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

# Situation 1. Google Test and Google Mock are shipped in library form.
# Use the libraries unless there we've been asked not to.
if (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

    if (NOT GTEST_PREFER_SOURCE_BUILD)

        find_package (GTest QUIET)

    endif (NOT GTEST_PREFER_SOURCE_BUILD)

    if (NOT GMOCK_PREFER_SOURCE_BUILD)

        # We must try to find google-mock first, if that is unavailable then
        # building gmock will build both it and google-test
        if (GTEST_FOUND)

            find_library (GMOCK_LIBRARY_PATH gmock)
            find_library (GMOCK_MAIN_LIBRARY_PATH gmock_main)

            # Find the Google Mock include directory by
            # searching the system paths
            find_path (GMOCK_INCLUDE_DIR_PATH
                       gmock/gmock.h)

            if (GMOCK_LIBRARY_PATH AND
                GMOCK_MAIN_LIBRARY_PATH AND
                GMOCK_INCLUDE_DIR_PATH)

                # Library forms are available and acceptable, we have found
                # both Google Test and Google Mock
                polysquare_import_utils_import_library (GTEST_LIBRARY
                                                        gtest STATIC
                                                        ${GTEST_LIBRARY_PATH})
                polysquare_import_utils_import_library (GMOCK_LIBRARY
                                                        gmock STATIC
                                                        ${GMOCK_LIBRARY_PATH})
                polysquare_import_utils_import_library (GTEST_MAIN_LIBRARY
                                                        gtest_main STATIC
                                                        ${GTEST_MAIN_LIBRARY_PATH})
                polysquare_import_utils_import_library (GMOCK_MAIN_LIBRARY
                                                        gmock_main STATIC
                                                        ${GMOCK_MAIN_LIBRARY_PATH})

                set (GMOCK_INCLUDE_DIR ${GMOCK_INCLUDE_DIR_PATH}
                     CACHE FILEPATH "" FORCE)
                set (GTEST_INCLUDE_DIR ${GTEST_INCLUDE_DIR_PATH}
                     CACHE FILEPATH "" FORCE)

                set (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT
                     ON CACHE BOOL "" FORCE)
                mark_as_advanced (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

                set (GTEST_FOUND TRUE)
                set (GMOCK_FOUND TRUE)

            endif (GMOCK_LIBRARY_PATH AND
                   GMOCK_MAIN_LIBRARY_PATH AND
                   GMOCK_INCLUDE_DIR_PATH)

        endif (GTEST_FOUND)

    endif (NOT GMOCK_PREFER_SOURCE_BUILD)

endif (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

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

# Situation 2. Google Mock was not shipped in source form, but Google
# Test was, and it is acceptable to use Google Mock in library form.
if (NOT GTEST_FOUND AND NOT GMOCK_FOUND AND NOT GMOCK_PREFER_SOURCE_BUILD)

    # Google Mock must be found in library form first, otherwise
    # we end up calling add_subdirectory twice.
    find_library (GMOCK_LIBRARY_PATH gmock)
    find_library (GMOCK_MAIN_LIBRARY_PATH gmock_main)

    if (GMOCK_LIBRARY_PATH AND GMOCK_MAIN_LIBRARY_PATH)

        # Find the the Google Test include directory
        # by searching the system-wide include directory
        # paths
        find_path (GTEST_INCLUDE_DIR_PATH
                   gtest/gtest.h)

        if (GTEST_INCLUDE_DIR_PATH)

            set (GTEST_INCLUDE_BASE "include/")
            _gmock_find_prefix_from_base (${GTEST_INCLUDE_BASE}
                                          ${GTEST_INCLUDE_DIR_PATH}
                                          GTEST_INCLUDE_PREFIX)

            find_path (GTEST_SRC_DIR
                       CMakeLists.txt
                       PATHS ${GTEST_INCLUDE_PREFIX}/src/gtest
                       NO_DEFAULT_PATH)

            if (GTEST_SRC_DIR)

                _add_external_project_with_gmock_cflags (GoogleMock
                                                         gtest-exports
                                                         OPTIONS
                                                         URL ${GTEST_SRC_DIR}
                                                         TARGETS
                                                         GTEST_LIBRARY
                                                         gtest
                                                         GTEST_MAIN_LIBRARY
                                                         gtest_main
                                                         INCLUDE_DIRS)

                polysquare_import_utils_import_library (GMOCK_LIBRARY
                                                        gmock STATIC
                                                        ${GMOCK_LIBRARY_PATH})
                polysquare_import_utils_import_library (GMOCK_MAIN_LIBRARY
                                                        gmock_main STATIC
                                                        ${GMOCK_MAIN_LIBRARY_PATH})

                set (GMOCK_INCLUDE_DIR ${GMOCK_INCLUDE_DIR_PATH}
                     CACHE FILEPATH "" FORCE)
                set (GTEST_INCLUDE_DIR ${GTEST_INCLUDE_DIR_PATH}
                     CACHE FILEPATH "" FORCE)

                set (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT
                     ON CACHE BOOL "" FORCE)
                mark_as_advanced (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

                set (GTEST_FOUND TRUE)
                set (GMOCK_FOUND TRUE)

            endif (GTEST_SRC_DIR)

        endif (GTEST_INCLUDE_DIR_PATH)

    endif (GMOCK_LIBRARY_PATH AND GMOCK_MAIN_LIBRARY_PATH)

endif (NOT GTEST_FOUND AND NOT GMOCK_FOUND AND NOT GMOCK_PREFER_SOURCE_BUILD)

# Situation 3. Either we don't want to use the library forms, or
# Google Test or Google Mock wasn't shipped in library form.
# Try to see if Google Mock was shipped in source form and build
# both libraries.
if (NOT GMOCK_ALWAYS_DOWNLOAD_SOURCES)

    if (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

        # Find the Google Mock include directory by
        # searching the system paths
        find_path (GMOCK_INCLUDE_DIR_PATH
                   gmock/gmock.h)
        find_path (GTEST_INCLUDE_DIR_PATH
                   gtest/gtest.h)

        if (GMOCK_INCLUDE_DIR_PATH AND GTEST_INCLUDE_DIR_PATH)

            set (GMOCK_INCLUDE_BASE "include/")
            _gmock_find_prefix_from_base (${GMOCK_INCLUDE_BASE}
                                          ${GMOCK_INCLUDE_DIR_PATH}
                                          GMOCK_INCLUDE_PREFIX)

            find_path (GMOCK_SRC_DIR
                       CMakeLists.txt
                       PATHS ${GMOCK_INCLUDE_PREFIX}/src/gmock
                       NO_DEFAULT_PATH)
            find_path (GTEST_SRC_DIR
                       CMakeLists.txt
                       PATHS ${GMOCK_INCLUDE_PREFIX}/src/gtest
                       NO_DEFAULT_PATH)

            if (GMOCK_SRC_DIR AND GTEST_SRC_DIR)

                # Because gmock tries to reference gtest on a relative path
                # to itself, copy the entire build-tree into a subdirectory
                set (GMOCK_TREE ${CMAKE_CURRENT_BINARY_DIR}/GoogleMock/tree)
                file (COPY ${GMOCK_SRC_DIR} DESTINATION ${GMOCK_TREE}
                      NO_SOURCE_PERMISSIONS)
                file (COPY ${GTEST_SRC_DIR} DESTINATION ${GMOCK_TREE}
                      NO_SOURCE_PERMISSIONS)

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

                set (GMOCK_INCLUDE_DIR ${GMOCK_INCLUDE_DIR_PATH}
                     CACHE FILEPATH "" FORCE)
                set (GTEST_INCLUDE_DIR ${GTEST_INCLUDE_DIR_PATH}
                     CACHE FILEPATH "" FORCE)

                set (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT
                     ON CACHE BOOL "" FORCE)
                mark_as_advanced (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

                set (GTEST_FOUND TRUE)
                set (GMOCK_FOUND TRUE)

            endif (GMOCK_SRC_DIR AND GTEST_SRC_DIR)

        endif (GMOCK_INCLUDE_DIR_PATH AND GTEST_INCLUDE_DIR_PATH)

    endif (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

endif (NOT GMOCK_ALWAYS_DOWNLOAD_SOURCES)

# Situation 4. Neither was shipped in source form.
# Set up an external project, download it and build it there.
if (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

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

    set (EXTPROJECT_TARGET GoogleMock)

    _add_external_project_with_gmock_cflags (${EXTPROJECT_TARGET} gmock-exports
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

    set (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT
         ON CACHE BOOL "" FORCE)
    mark_as_advanced (_GMOCK_AND_GTEST_INSIDE_FINDING_PROJECT)

    set (GTEST_FOUND 1)
    set (GMOCK_FOUND 1)

endif (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

function (_override_gmock_compile_flags TARGET)

    set_property (TARGET ${TARGET}
                  APPEND_STRING
                  PROPERTY COMPILE_FLAGS
                  " ${GMOCK_CXX_FLAGS}")

endfunction (_override_gmock_compile_flags)

if (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

    if (GoogleMock_FIND_REQUIRED)

        message (SEND_ERROR "Could not find Google Test and Google Mock")

    endif (GoogleMock_FIND_REQUIRED)

else (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

    # Set the library names as variables for other binaries to use.
    set (GTEST_LIBRARY gtest)
    set (GTEST_MAIN_LIBRARY gtest_main)
    set (GMOCK_LIBRARY gmock)
    set (GMOCK_MAIN_LIBRARY gmock_main)
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

    if (NOT GoogleMock_FIND_QUIETLY)

        message (STATUS "Google Test and Google Mock Found")

    endif (NOT GoogleMock_FIND_QUIETLY)

endif (NOT GTEST_FOUND OR NOT GMOCK_FOUND)
