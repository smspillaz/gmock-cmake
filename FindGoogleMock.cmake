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
#                      You should only link with this libary if you do not
#                      need to overload the testing environment with a
#                      custom one.
# GMOCK_LIBRARY : Linker line for the Google Mock library
# GMOCK_MAIN_LIBRARY : Linker line for the Google Mock main () library.
#                      You should only link with this libary if you do not
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
#    GTEST_EXTERNAL_SET_INCLUDE_DIR
#    GMOCK_EXTERNAL_SET_INCLUDE_DIR
#    GTEST_EXTERNAL_SET_LIBRARY
#    GMOCK_EXTERNAL_SET_LIBRARY
#    GTEST_EXTERNAL_SET_MAIN_LIBRARY
#    GMOCK_EXTERNAL_SET_MAIN_LIBRARY
#
#    A parent should also provide the following variable, as a dependency
#    to add in order to ensure that the Google Test and Google Mock
#    libraries are available when this target is built.
#
#    GTEST_AND_GMOCK_EXTERNAL_SET_DEPENDENCY
#
# 1. Google Test and Google Mock are shipped as a pre-built library
#    in which case we can use both and set the include dirs.
# 2. Only Google Mock is shipped in source-form, including a distribution
#    of Google Test. Both must be built and linked in.
# 3. Google Mock is shipped as a pre-built library, but Google Test
#    is shipped in source-form, in which case the latter must be built
#    from source and the former linked in.
# 4. It may not be shipped or available at all, in which case, we must
#    add an external project rule to download, configure and build it
#    at build time. We then import the resultant library.
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

find_package (Threads REQUIRED)

option (GTEST_PREFER_SOURCE_BUILD
        "Whether or not to prefer a source build of Google Test." OFF)
option (GMOCK_PREFER_SOURCE_BUILD
        "Whether or not to prefer a source build of Google Mock." OFF)

macro (_import_library library_target location)

    add_library (${library_target} STATIC IMPORTED GLOBAL)
    set_target_properties (${library_target}
                           PROPERTIES IMPORTED_LOCATION ${location})

endmacro (_import_library)

macro (_import_library_from_extproject library_target location extproj)

    _import_library (${library_target} ${location})
    set_target_properties (${library_target}
                           PROPERTIES EXTERNAL_PROJECT ${extproj})
    add_dependencies (${library_target} ${extproj})

endmacro (_import_library_from_extproject)

# Already found, return
if (GTEST_FOUND AND GMOCK_FOUND)

    return ()

endif (GTEST_FOUND AND GMOCK_FOUND)

# Situation 0. Google Test and Google Mock were provided by the user.
if (GTEST_EXTERNAL_SET_INCLUDE_DIR AND
    GMOCK_EXTERNAL_SET_INCLUDE_DIR AND
    GTEST_EXTERNAL_SET_LIBRARY AND
    GMOCK_EXTERNAL_SET_LIBRARY AND
    GTEST_EXTERNAL_SET_MAIN_LIBRARY AND
    GMOCK_EXTERNAL_SET_MAIN_LIBRARY)

    set (GTEST_INCLUDE_DIR ${GTEST_EXTERNAL_SET_INCLUDE_DIR})
    set (GMOCK_INCLUDE_DIR ${GMOCK_EXTERNAL_SET_INCLUDE_DIR})

    _import_library (gtest ${GTEST_EXTERNAL_SET_LIBRARY})
    _import_library (gmock ${GMOCK_EXTERNAL_SET_LIBRARY})
    _import_library (gtest_main ${GTEST_EXTERNAL_SET_MAIN_LIBRARY})
    _import_library (gmock_main ${GMOCK_EXTERNAL_SET_MAIN_LIBRARY})

    set (GTEST_FOUND 1)
    set (GMOCK_FOUND 1)

    # We want to specify this so that the target names
    # are re-used.
    set (GTEST_CREATED_TARGET 1)
    set (GMOCK_CREATED_TARGET 1)

endif (GTEST_EXTERNAL_SET_INCLUDE_DIR AND
       GMOCK_EXTERNAL_SET_INCLUDE_DIR AND
       GTEST_EXTERNAL_SET_LIBRARY AND
       GMOCK_EXTERNAL_SET_LIBRARY AND
       GTEST_EXTERNAL_SET_MAIN_LIBRARY AND
       GMOCK_EXTERNAL_SET_MAIN_LIBRARY)

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

            find_library (GMOCK_LIBRARY gmock)
            find_library (GMOCK_MAIN_LIBRARY gmock_main)

            # Find the Google Mock include directory by
            # searching the system paths
            find_path (GMOCK_INCLUDE_DIR
                       gmock/gmock.h)

            if (GMOCK_LIBRARY AND GMOCK_MAIN_LIBRARY AND GMOCK_INCLUDE_DIR)

                # Library forms are available and acceptable, we have found
                # both Google Test and Google Mock

                set (GTEST_FOUND TRUE)
                set (GMOCK_FOUND TRUE)

            endif (GMOCK_LIBRARY AND GMOCK_MAIN_LIBRARY AND GMOCK_INCLUDE_DIR)

        endif (GTEST_FOUND)

    endif (NOT GMOCK_PREFER_SOURCE_BUILD)

endif (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

function (_find_prefix_from_base INCLUDE_BASE INCLUDE_DIR PREFIX_VAR)

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

endfunction (_find_prefix_from_base)

# Situation 2. Either we don't want to use the library forms, or
# Google Test or Google Mock wasn't shipped in library form.
# Try to see if Google Mock was shipped in source form and build
# both libraries.
if (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

    # Find the Google Mock include directory by
    # searching the system paths
    find_path (GMOCK_INCLUDE_DIR
               gmock/gmock.h)

    if (GMOCK_INCLUDE_DIR)

        set (GMOCK_INCLUDE_BASE "include/")
        _find_prefix_from_base (${GMOCK_INCLUDE_BASE}
                                ${GMOCK_INCLUDE_DIR}
                                GMOCK_INCLUDE_PREFIX)

        find_path (GMOCK_SRC_DIR
                   CMakeLists.txt
                   PATHS ${GMOCK_INCLUDE_PREFIX}/src/gmock
                   NO_DEFAULT_PATH)

        if (GMOCK_SRC_DIR)

            set (GMOCK_INCLUDE_DIR ${GMOCK_INCLUDE_DIR})
            set (GTEST_INCLUDE_DIR ${GMOCK_SRC_DIR}/gtest/include)

            add_subdirectory (${GMOCK_SRC_DIR}
                              ${CMAKE_CURRENT_BINARY_DIR}/src/gmock)

            set (GTEST_CREATED_TARGET TRUE)
            set (GMOCK_CREATED_TARGET TRUE)

            set (GTEST_FOUND TRUE)
            set (GMOCK_FOUND TRUE)

        endif (GMOCK_SRC_DIR)

    endif (GMOCK_INCLUDE_DIR)

endif (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

# Situation 3. Google Mock was not shipped in source form, but Google
# Test was, and it is acceptable to use Google Mock in library form.
if (NOT GTEST_FOUND AND NOT GMOCK_FOUND AND NOT GMOCK_PREFER_SOURCE_BUILD)

    # Find the the Google Test include directory
    # by searching the system-wide include directory
    # paths
    find_path (GTEST_INCLUDE_DIR
               gtest/gtest.h)

    if (GTEST_INCLUDE_DIR)

        set (GTEST_INCLUDE_BASE "include/")
        _find_prefix_from_base (${GTEST_INCLUDE_BASE}
                                ${GTEST_INCLUDE_DIR}
                                GTEST_INCLUDE_PREFIX)

        find_path (GTEST_SRC_DIR
                   CMakeLists.txt
                   PATHS ${GTEST_INCLUDE_PREFIX}/src/gtest
                   NO_DEFAULT_PATH)

        if (GTEST_SRC_DIR)

            add_subdirectory (${GTEST_SRC_DIR}
                              ${CMAKE_CURRENT_BINARY_DIR}/src/gtest)

            set (GTEST_CREATED_TARGET TRUE)

            find_library (GMOCK_LIBRARY gmock)
            find_library (GMOCK_MAIN_LIBRARY gmock_main)

            if (GMOCK_LIBRARY AND GMOCK_MAIN_LIBRARY)

                set (GTEST_FOUND TRUE)
                set (GMOCK_FOUND TRUE)

            endif (GMOCK_LIBRARY AND GMOCK_MAIN_LIBRARY)

        endif (GTEST_SRC_DIR)

    endif (GTEST_INCLUDE_DIR)

endif (NOT GTEST_FOUND AND NOT GMOCK_FOUND AND NOT GMOCK_PREFER_SOURCE_BUILD)

# Situation 4. Neither was shipped in source form.
# Set up an external project, download it and build it there.

# Workaround for some generators setting a different output directory
function (_get_build_directory_suffix_for_generator SUFFIX)

    if (${CMAKE_GENERATOR} STREQUAL "Xcode")

        if (CMAKE_BUILD_TYPE)

            set (${SUFFIX} ${CMAKE_BUILD_TYPE} PARENT_SCOPE)

        else (CMAKE_BUILD_TYPE)

            set (${SUFFIX} "Debug" PARENT_SCOPE)

        endif (CMAKE_BUILD_TYPE)

    endif (${CMAKE_GENERATOR} STREQUAL "Xcode")

endfunction (_get_build_directory_suffix_for_generator)

if (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

    include (ExternalProject)

    set (BIN_DIR ${CMAKE_CURRENT_BINARY_DIR})

    set (GMOCK_EXT_PROJECT_NAME GoogleMock)
    set (GMOCK_PREFIX ${BIN_DIR}/__gmock)
    set (GMOCK_SOURCE_DIR ${GMOCK_PREFIX}/src/${GMOCK_EXT_PROJECT_NAME})
    set (GMOCK_DEFAULT_BINARY_DIR ${GMOCK_SOURCE_DIR}-build)
    set (GTEST_DEFAULT_BINARY_DIR ${GMOCK_DEFAULT_BINARY_DIR}/gtest)
    set (GTEST_SOURCE_DIR ${GMOCK_SOURCE_DIR}/gtest)
    set (GMOCK_URL "http://googlemock.googlecode.com/files/gmock-1.7.0.zip")

    set (EXTPROJECT_TARGET GoogleMock)

    ExternalProject_Add (${EXTPROJECT_TARGET}
                         URL ${GMOCK_URL}
                         PREFIX ${GMOCK_PREFIX}
                         INSTALL_COMMAND "")

    set (GTEST_LIBRARY gtest)
    set (GTEST_MAIN_LIBRARY gtest_main)
    set (GMOCK_LIBRARY gmock)
    set (GMOCK_MAIN_LIBRARY gmock_main)

    set (BUILD_SUFFIX)
    _get_build_directory_suffix_for_generator (BUILD_SUFFIX)

    set (GMOCK_LIBRARY_PATH
         ${GMOCK_DEFAULT_BINARY_DIR}/${BUILD_SUFFIX}/libgmock.a)
    set (GMOCK_MAIN_LIBRARY_PATH
         ${GMOCK_DEFAULT_BINARY_DIR}/${BUILD_SUFFIX}/libgmock_main.a)
    set (GTEST_LIBRARY_PATH
         ${GTEST_DEFAULT_BINARY_DIR}/${BUILD_SUFFIX}/libgtest.a)
    set (GTEST_MAIN_LIBRARY_PATH
         ${GTEST_DEFAULT_BINARY_DIR}/${BUILD_SUFFIX}/libgtest_main.a)

    set (GTEST_INCLUDE_DIR ${GTEST_SOURCE_DIR}/include)
    set (GMOCK_INCLUDE_DIR ${GMOCK_SOURCE_DIR}/include)

    # Tell CMake that we've imported some libraries
    _import_library_from_extproject (${GMOCK_LIBRARY}
                                     ${GMOCK_LIBRARY_PATH}
                                     ${EXTPROJECT_TARGET})
    _import_library_from_extproject (${GMOCK_MAIN_LIBRARY}
                                     ${GMOCK_MAIN_LIBRARY_PATH}
                                     ${EXTPROJECT_TARGET})
    _import_library_from_extproject (${GTEST_LIBRARY}
                                     ${GTEST_LIBRARY_PATH}
                                     ${EXTPROJECT_TARGET})
    _import_library_from_extproject (${GTEST_MAIN_LIBRARY}
                                     ${GTEST_MAIN_LIBRARY_PATH}
                                     ${EXTPROJECT_TARGET})

    # We've already set the library names here, so no need to
    # set them again later

    set (GTEST_FOUND 1)
    set (GMOCK_FOUND 1)

endif (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

if (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

    if (GoogleMock_FIND_REQUIRED)

        message (SEND_ERROR "Could not find Google Test and Google Mock")

    endif (GoogleMock_FIND_REQUIRED)

else (NOT GTEST_FOUND OR NOT GMOCK_FOUND)

    if (GTEST_CREATED_TARGET)

        set (GTEST_LIBRARY gtest)
        set (GTEST_MAIN_LIBRARY gtest_main)

    endif (GTEST_CREATED_TARGET)

    if (GMOCK_CREATED_TARGET)

        set (GMOCK_LIBRARY gmock)
        set (GMOCK_MAIN_LIBRARY gmock_main)

    endif (GMOCK_CREATED_TARGET)

    set (GTEST_BOTH_LIBRARIES
         ${CMAKE_THREAD_LIBS_INIT}
         ${GTEST_LIBRARY}
         ${GTEST_MAIN_LIBRARY})

    if (NOT GoogleMock_FIND_QUIETLY)

        message (STATUS "Google Test and Google Mock Found")

    endif (NOT GoogleMock_FIND_QUIETLY)

endif (NOT GTEST_FOUND OR NOT GMOCK_FOUND)
