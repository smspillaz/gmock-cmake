# GoogleMockLibraryUtils.cmake
#
# CMake Helper library for importing and exporting Google Mock external project
# libraries
#
# See LICENCE.md for Copyright information.

include (imported-project-utils/ImportedProjectUtils)

macro (_google_mock_append_dependencies LIBRARY DEPENDENCIES)

    if (TARGET ${LIBRARY})

        list (APPEND ${DEPENDENCIES} ${LIBRARY})

    endif (TARGET ${LIBRARY})

endmacro (_google_mock_append_dependencies)

function (google_mock_get_forward_variables DEPENDENCIES_RETURN
                                            NAMESPACES_RETURN)

    set (LIBRARIES_TO_DEPEND_ON
         GTEST_LIBRARY
         GMOCK_LIBRARY
         GTEST_MAIN_LIBRARY
         GMOCK_MAIN_LIBRARY)

    foreach (LIBRARY ${LIBRARIES_TO_DEPEND_ON})

        if (NOT DEFINED ${LIBRARY})

            message (FATAL_ERROR "${LIBRARY} must be defined. Have you called "
                                 "find_package (GoogleMock) yet?")

        endif (NOT DEFINED ${LIBRARY})

        _google_mock_append_dependencies (${${LIBRARY}} DEPENDENCIES)

    endforeach ()

    set (${NAMESPACES_RETURN}
         GTEST GMOCK
         PARENT_SCOPE)

    set (${DEPENDENCIES_RETURN}
         ${DEPENDENCIES}
         PARENT_SCOPE)

endfunction (google_mock_get_forward_variables)