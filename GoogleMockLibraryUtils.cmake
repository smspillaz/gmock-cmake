# GoogleMockLibraryUtils.cmake
#
# CMake Helper library for importing and exporting Google Mock external project
# libraries
#
# See LICENCE.md for Copyright information.

include (imported-project-utils/ImportedProjectUtils)

macro (_google_mock_append_dependencies LIBRARY DEPENDENCIES)

    if (TARGET ${${LIBRARY}})

        list (APPEND ${DEPENDENCIES} ${${LIBRARY}})

    endif (TARGET ${${LIBRARY}})

endmacro (_google_mock_append_dependencies)

macro (_google_mock_append_cache_library_path CACHE_OPTION
                                              LIBRARY
                                              CACHE_LINES)

    polysquare_import_utils_get_library_location_from_variable (${LIBRARY}
                                                                RESULT)
    polysquare_import_utils_append_cache_definition (${CACHE_OPTION}
                                                     ${RESULT}
                                                     ${CACHE_LINES})

endmacro (_google_mock_append_cache_library_path)

macro (_google_mock_append_extproject_variables LIBRARY
                                                CACHE_ARGUMENT_LINE
                                                DEPENDENCIES
                                                CACHE_OPTION)

    _google_mock_append_cache_library_path (${CACHE_OPTION}
                                            ${LIBRARY}
                                            ${CACHE_ARGUMENT_LINE})
    _google_mock_append_dependencies (${LIBRARY} ${DEPENDENCIES})

endmacro (_google_mock_append_extproject_variables)

function (google_mock_get_cache_lines_and_deps_from_found CACHE_LINES
                                                          DEPENDENCIES)

    if (NOT GTEST_INCLUDE_DIR OR
        NOT GMOCK_INCLUDE_DIR OR
        NOT GTEST_LIBRARY OR
        NOT GMOCK_LIBRARY OR
        NOT GTEST_MAIN_LIBRARY OR
        NOT GMOCK_MAIN_LIBRARY)

        message (FATAL_ERROR "Google Mock was not found and set up yet. "
                             "Cannot pass on parameters in cache.")

    endif (NOT GTEST_INCLUDE_DIR OR
           NOT GMOCK_INCLUDE_DIR OR
           NOT GTEST_LIBRARY OR
           NOT GMOCK_LIBRARY OR
           NOT GTEST_MAIN_LIBRARY OR
           NOT GMOCK_MAIN_LIBRARY)

    set (EXTERNAL_PROJECT_CACHE_DEFINITIONS)
    set (EXTERNAL_PROJECT_DEPENDENCIES)
    polysquare_import_utils_append_cache_definition (GTEST_EXTERNAL_SET_INCLUDE_DIR
                                                     GTEST_INCLUDE_DIR
                                                     EXTERNAL_PROJECT_CACHE_DEFINITIONS)
    polysquare_import_utils_append_cache_definition (GMOCK_EXTERNAL_SET_INCLUDE_DIR
                                                     GMOCK_INCLUDE_DIR
                                                     EXTERNAL_PROJECT_CACHE_DEFINITIONS)

    _google_mock_append_extproject_variables (GTEST_LIBRARY
                                              GTEST_EXTERNAL_SET_LIBRARY
                                              EXTERNAL_PROJECT_DEPENDENCIES
                                              EXTERNAL_PROJECT_CACHE_DEFINITIONS)
    _google_mock_append_extproject_variables (GMOCK_LIBRARY
                                              GMOCK_EXTERNAL_SET_LIBRARY
                                              EXTERNAL_PROJECT_DEPENDENCIES
                                              EXTERNAL_PROJECT_CACHE_DEFINITIONS)
    _google_mock_append_extproject_variables (GTEST_MAIN_LIBRARY
                                              GTEST_EXTERNAL_SET_MAIN_LIBRARY
                                              EXTERNAL_PROJECT_DEPENDENCIES
                                              EXTERNAL_PROJECT_CACHE_DEFINITIONS)
    _google_mock_append_extproject_variables (GMOCK_MAIN_LIBRARY
                                              GMOCK_EXTERNAL_SET_MAIN_LIBRARY
                                              EXTERNAL_PROJECT_DEPENDENCIES
                                              EXTERNAL_PROJECT_CACHE_DEFINITIONS)

    set (${CACHE_LINES} ${EXTERNAL_PROJECT_CACHE_DEFINITIONS} PARENT_SCOPE)
    set (${DEPENDENCIES} ${EXTERNAL_PROJECT_DEPENDENCIES} PARENT_SCOPE)

endfunction (google_mock_get_cache_lines_and_deps_from_found)