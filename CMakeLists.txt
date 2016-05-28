# /CMakeLists.txt
#
# Main entry point for GMockTests tests.
#
# See /LICENCE.md for Copyright information
include ("${CMAKE_CURRENT_LIST_DIR}/conanbuildinfo.cmake")
set (CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_LIST_DIR}"
     ${CONAN_CMAKE_MODULE_PATH}  # NOLINT:correctness/quotes
     ${CMAKE_MODULE_PATH})  # NOLINT:correctness/quotes

cmake_minimum_required (VERSION 2.8)

include ("cmake/cmake-module-common/Common" OPTIONAL)

include (AddSimpleGTestHelper)

# Checks that when we set the GMOCK_ALWAYS_DOWNLOAD_SOURCES
# option that an external project is created called 'GTEST'
function (gmock_test_always_download_sources_creates_external_project)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    function (gmock_verify)

        cmake_unit_assert_that ("${BINARY_DIR}/GoogleMock"
                                exists_as_file)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()

# Checks that on setting GMOCK_DOWNLOAD_VERSION to "1.70"
# that we download the released version of Google Mock
# and not the GIT version.
function (gmock_test_compiler_flags_passed_for_external_project_build)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
        set (GMOCK_DOWNLOAD_VERSION "1.7.0" CACHE STRING "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    # Unfortunately, the output of the external project is not captured in the
    # stdout or stderr of this test, so we'll only know that the flags were
    # passed if the build was successful on compilers that have those warnings
    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure)

endfunction ()

# Check that upon setting GTEST_PREFER_SOURCE_BUILD
# we can still build a usable google-mock
function (gmock_test_compiler_flags_passed_for_source_build_of_g_mock)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GMOCK_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND gmock_configure)

endfunction ()

# Check that compiler flags are passed for source builds of GTest.
function (gmock_test_compiler_flags_passed_for_source_build_of_g_test)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GTEST_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    cmake_unit_configure_config_only_test (INVOKE_CONFIGURE OPTIONS
                                                            LANGUAGES
                                                            C
                                                            CXX
                                           CONFIGURE COMMAND gmock_configure)

endfunction ()

# Checks that on setting GMOCK_DOWNLOAD_VERSION to "GIT"
# we don't run "GoogleMock-gitupdate" by default
function (gmock_test_download_git_does_not_update_by_default)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
        set (GMOCK_DOWNLOAD_VERSION "GIT" CACHE STRING "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    function (gmock_verify)

        set (METAPROJECT_BINARY_DIR
             "${BINARY_DIR}/GoogleMock/GoogleMock-Meta/build")
        set (BUILD_METAPROJECT_OUTPUT_FILE
             "${METAPROJECT_BINARY_DIR}/BuildMetaProjectOutput.txt")

        if ("${CMAKE_GENERATOR}" MATCHES "NMake.*|Visual.*")

            set (REGEX "^.*git pull.*$")

        else ()

            set (REGEX "^.*GoogleMock-gitupdate.*$")

        endif ()

        cmake_unit_assert_that ("${BUILD_METAPROJECT_OUTPUT_FILE}"
                                not file_contents any_line matches_regex
                                "${REGEX}")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()

# Checks that on setting GMOCK_DOWNLOAD_VERSION to "GIT"
# we run "GoogleMock-gitclone"
function (gmock_test_download_git_runs_git_clone)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
        set (GMOCK_DOWNLOAD_VERSION "GIT" CACHE STRING "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    function (gmock_verify)

        set (METAPROJECT_BINARY_DIR
             "${BINARY_DIR}/GoogleMock/GoogleMock-Meta/build")
        set (BUILD_METAPROJECT_OUTPUT_FILE
             "${METAPROJECT_BINARY_DIR}/BuildMetaProjectOutput.txt")

        if ("${CMAKE_GENERATOR}" MATCHES "NMake.*|Visual.*")

            set (REGEX "^.*Cloning.*$")

        else ()

            set (REGEX "^.*GoogleMock-gitclone.*$")

        endif ()

        cmake_unit_assert_that ("${BUILD_METAPROJECT_OUTPUT_FILE}" file_contents
                                any_line
                                matches_regex
                                "${REGEX}")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()

# Checks that on setting GMOCK_DOWNLOAD_VERSION to "1.70"
# that we download the released version of Google Mock
# and not the git version.
function (gmock_test_download_version170_unpacks_release_tarball)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
        set (GMOCK_DOWNLOAD_VERSION "1.7.0" CACHE STRING "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    function (gmock_verify)

        set (GMOCK_PROJECT_DIRECTORY "${BINARY_DIR}/GoogleMock")
        cmake_unit_assert_that ("${GMOCK_PROJECT_DIRECTORY}/src/gmock-1.7.0.zip"
                                exists_as_file)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()

# Checks that on setting GMOCK_DOWNLOAD_VERSION to "GIT"
# and GMOCK_FORCE_UPDATE to ON that "GoogleMock-gitupdate" is run.
function (gmock_test_force_updates_option_allows_update)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GMOCK_ALWAYS_DOWNLOAD_SOURCES ON CACHE BOOL "" FORCE)
        set (GMOCK_DOWNLOAD_VERSION "GIT" CACHE STRING "" FORCE)
        set (GMOCK_FORCE_UPDATE ON CACHE BOOL "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    function (gmock_verify)

        set (METAPROJECT_BINARY_DIR
             "${BINARY_DIR}/GoogleMock/GoogleMock-Meta/build")
        set (BUILD_METAPROJECT_OUTPUT_FILE
             "${METAPROJECT_BINARY_DIR}/BuildMetaProjectOutput.txt")

        set (REGEX "^.*GoogleMock-gitupdate.*$")

        cmake_unit_assert_that ("${BUILD_METAPROJECT_OUTPUT_FILE}"
                                file_contents
                                any_line
                                matches_regex
                                "${REGEX}")

    endfunction ()

    cmake_unit_configure_test (PRECONFIGURE OPTIONS SKIP_SYSTEM_REGEX "Windows"
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()

# Find Google Mock normally (preferring a source build so that we download it)
# and build it as an external project. Then add a new external project and
# inject the Google Mock paths into its cache and have it build a simple test.
function (gmock_test_from_parent_in_external_project)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GTEST_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
        set (GMOCK_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
        find_package (GMOCK REQUIRED)
        set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT "project (External)\n"
             "cmake_minimum_required (VERSION\n"
             "                        ${CMAKE_MINIMUM_REQUIRED_VERSION})\n")
        foreach (PATH ${CMAKE_MODULE_PATH}) # NOLINT:correctness/quotes
            set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
                 "${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT}"
                 "set (CMAKE_MODULE_PATH\n"
                 "     ${PATH}\n"
                 "     \${CMAKE_MODULE_PATH})\n")
        endforeach ()

        # The BINARY_DIR in the subproject
        set (CUR_BIN_DIR "\${CMAKE_CURRENT_BINARY_DIR}")

        set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
             "${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT}\n"
             "find_package (GMOCK REQUIRED)\n"
             "include (AddSimpleGTestHelper)\n"
             "gmock_add_simple_gtest_helper (\"${CUR_BIN_DIR}\")\n"
             "export (TARGETS simple_test FILE extproj-exports.cmake)\n")
        set (EXTERNAL_PROJECT_DIRECTORY "${BINARY_DIR}/External")
        set (EXTERNAL_PROJECT_BINARY_DIRECTORY
             "${EXTERNAL_PROJECT_DIRECTORY}/build")
        set (EXTERNAL_PROJECT_CMAKELISTS_TXT
             "${EXTERNAL_PROJECT_DIRECTORY}/CMakeLists.txt")
        file (MAKE_DIRECTORY "${EXTERNAL_PROJECT_DIRECTORY}")
        file (WRITE ${EXTERNAL_PROJECT_CMAKELISTS_TXT}
              ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT})
        gmock_get_forward_variables (DEPENDENCIES NAMESPACES)
        psq_import_external_project (ELGT
                                     extproj-exports
                                     DEPENDS
                                     ${DEPENDENCIES}
                                     OPTIONS
                                     SOURCE_DIR
                                     "${EXTERNAL_PROJECT_DIRECTORY}"
                                     BINARY_DIR
                                     "${EXTERNAL_PROJECT_BINARY_DIRECTORY}"
                                     NAMESPACES
                                     ${NAMESPACES}
                                     VERBOSE_BUILD)

    endfunction ()

    function (gmock_verify)

        set (EXTERNAL_PROJECT_DIRECTORY "${BINARY_DIR}/External")
        set (EXTERNAL_PROJECT_BINARY_DIRECTORY
             "${EXTERNAL_PROJECT_DIRECTORY}/build")
        set (EXPORTS_FILE
             "${EXTERNAL_PROJECT_BINARY_DIRECTORY}/extproj-exports.cmake")
        _gmock_get_target_location_from_exports ("${EXPORTS_FILE}" simple_test
                                                 TEST_BINARY)
        cmake_unit_assert_that ("${TEST_BINARY}" executes_with_success)
        set (SUBPROJECT_STAMP_DIR
             "${BINARY_DIR}/ELGT/src/stamp/")
        set (SUBPROJECT_BUILD_LOG
             "${SUBPROJECT_STAMP_DIR}/ELGT-build-out.log")
        set (GMOCK_SUBPROJECT_BINARY_DIR
             "${BINARY_DIR}/GoogleMock/src/build")

        if ("${CMAKE_GENERATOR}" MATCHES "NMake.*|Visual.*")

            # On Windows generators the link libraries come before
            # the library name. Its also very difficult to pass
            # a fully-escaped string containing the build directory
            # so just pass the non-qualified name of the directory.
            set (LINKED_TO_PARENT_GTEST_REGEX
                 "^.*External.*gtest.*simple_test.*$")
            set (LINKED_TO_PARENT_GMOCK_REGEX
                 "^.*External.*gmock.*simple_test.*$")

        else ()

            set (LINKED_TO_PARENT_GTEST_REGEX
                 "^.*simple_test.*${GMOCK_SUBPROJECT_BINARY_DIR}/.*gtest.*$")
            set (LINKED_TO_PARENT_GMOCK_REGEX
                 "^.*simple_test.*${GMOCK_SUBPROJECT_BINARY_DIR}/.*gmock.*$")

        endif ()

        cmake_unit_assert_that (${SUBPROJECT_BUILD_LOG}
                                file_contents
                                any_line
                                matches_regex
                                "${LINKED_TO_PARENT_GTEST_REGEX}")
        cmake_unit_assert_that (${SUBPROJECT_BUILD_LOG}
                                file_contents
                                any_line
                                matches_regex
                                "${LINKED_TO_PARENT_GMOCK_REGEX}")

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()


# Get target locations from a built external project tree's exports file
function (_gmock_get_target_location_from_exports EXPORTS
                                                  TARGET
                                                  LOCATION_RETURN)

    # We create a new project which includes the exports file (as we
    # cannot do so whilst in script mode) and then prints the location
    # on the stderr. We'll capture this and return it.
    set (DETERMINE_LOCATION_DIRECTORY
         "${BINARY_DIR}/determine_location_for_${TARGET}")
    set (DETERMINE_LOCATION_BINARY_DIRECTORY
         "${DETERMINE_LOCATION_DIRECTORY}/build")
    set (DETERMINE_LOCATION_CAPTURE
         "${DETERMINE_LOCATION_BINARY_DIRECTORY}/Capture")
    set (DETERMINE_LOCATION_CMAKELISTS_TXT_FILE
         "${DETERMINE_LOCATION_DIRECTORY}/CMakeLists.txt")
    set (DETERMINE_LOCATION_CMAKELISTS_TXT
         "include (\"${EXPORTS}\")\n"
         "get_property (LOCATION TARGET ${TARGET} PROPERTY LOCATION)\n"
         "file (WRITE \"${DETERMINE_LOCATION_CAPTURE}\" \"\${LOCATION}\")\n")

    string (REPLACE ";" ""
            DETERMINE_LOCATION_CMAKELISTS_TXT
            "${DETERMINE_LOCATION_CMAKELISTS_TXT}")

    file (MAKE_DIRECTORY "${DETERMINE_LOCATION_DIRECTORY}")
    file (MAKE_DIRECTORY "${DETERMINE_LOCATION_BINARY_DIRECTORY}")
    file (WRITE "${DETERMINE_LOCATION_CMAKELISTS_TXT_FILE}"
          "${DETERMINE_LOCATION_CMAKELISTS_TXT}")

    set (DETERMINE_LOCATION_OUTPUT_LOG
         "${DETERMINE_LOCATION_BINARY_DIRECTORY}/DetermineLocationOutput.txt")
    set (DETERMINE_LOCATION_ERROR_LOG
         "${DETERMINE_LOCATION_BINARY_DIRECTORY}/DetermineLocationError.txt")

    execute_process (COMMAND "${CMAKE_COMMAND}" -Wno-dev
                     "${DETERMINE_LOCATION_DIRECTORY}"
                     OUTPUT_FILE ${DETERMINE_LOCATION_OUTPUT_LOG}
                     ERROR_FILE ${DETERMINE_LOCATION_ERROR_LOG}
                     RESULT_VARIABLE RESULT
                     WORKING_DIRECTORY "${DETERMINE_LOCATION_BINARY_DIRECTORY}")

    if (NOT RESULT EQUAL 0)

        message (FATAL_ERROR "Error whilst getting location of ${TARGET}\n"
                             "See ${DETERMINE_LOCATION_ERROR_LOG} for details")

    endif ()

    file (READ ${DETERMINE_LOCATION_CAPTURE} LOCATION)
    set (${LOCATION_RETURN} "${LOCATION}" PARENT_SCOPE)

endfunction ()

# Tests that GMock can be built as an external project
# and linked to.
function (gmock_test_gmock_external_project)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    function (gmock_verify)

        set (EXPORTS_FILE "${BINARY_DIR}/simpletest-exports.cmake")
        _gmock_get_target_location_from_exports ("${EXPORTS_FILE}" simple_test
                                                 TEST_BINARY)
        cmake_unit_assert_that ("${TEST_BINARY}" executes_with_success)

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()

function (_gmock_external_project_verify)

    set (EXPORTS_FILE
         "${BINARY_DIR}/simpletest-exports.cmake")
    _gmock_get_target_location_from_exports ("${EXPORTS_FILE}"
                                             simple_test
                                             TEST_BINARY)

    cmake_unit_assert_that ("${TEST_BINARY}" exists_as_file)
    cmake_unit_assert_that ("${TEST_BINARY}" executes_with_success)

endfunction ()


# Check that upon setting GTEST_PREFER_SOURCE_BUILD and
# GMOCK_PREFER_SOURCE_BUILD  we can still build a usable
# google-mock
function (gmock_test_prefer_source_build_for_both)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GTEST_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
        set (GMOCK_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    function (gmock_verify)

        _gmock_external_project_verify ()

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()

# Check that upon setting GMOCK_PREFER_SOURCE_BUILD
# we can still build a usable google-mock
function (gmock_test_prefer_source_build_for_g_mock)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GMOCK_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    function (gmock_verify)

        _gmock_external_project_verify ()

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()

# Check that upon setting GTEST_PREFER_SOURCE_BUILD
# we can still build a usable google-mock
function (gmock_test_prefer_source_build_for_g_test)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (gmock_configure)

        set (GTEST_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
        find_package (GMOCK REQUIRED)
        gmock_add_simple_gtest_helper ("${BINARY_DIR}")

    endfunction ()

    function (gmock_verify)

        _gmock_external_project_verify ()

    endfunction ()

    cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                               CONFIGURE COMMAND gmock_configure
                               VERIFY COMMAND gmock_verify)

endfunction ()

set (_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

set (CMAKE_FILES
     "${_CURRENT_LIST_DIR}/CheckForGoogleMockCompilerFlags.cmake"
     "${_CURRENT_LIST_DIR}/FindGMOCK.cmake"
     "${_CURRENT_LIST_DIR}/GoogleMockLibraryUtils.cmake"
     "${_CURRENT_LIST_DIR}/CMakeLists.txt")
set (MARKDOWN_FILES
     "${_CURRENT_LIST_DIR}/LICENCE.md"
     "${_CURRENT_LIST_DIR}/README.md")

if (COMMAND cmake_module_add_common_targets)

    cmake_module_add_common_targets (NAMESPACE "gmock"
                                     CMAKE_FILES ${CMAKE_FILES}
                                     DOCUMENTATION_FILES ${MARKDOWN_FILES})

endif ()
