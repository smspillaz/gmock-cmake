# /tests/GetBuildDirectorySuffixForGeneratorHelper.cmake
# Get target locations from a built external project tree's exports file
#
# See LICENCE.md for Copyright information

function (get_target_location_from_exports EXPORTS TARGET LOCATION_RETURN)

    # We create a new project which includes the exports file (as we
    # cannot do so whilst in script mode) and then prints the location
    # on the stderr. We'll capture this and return it.
    set (DETERMINE_LOCATION_DIRECTORY
         ${CMAKE_CURRENT_BINARY_DIR}/determine_location_for_${TARGET})
    set (DETERMINE_LOCATION_BINARY_DIRECTORY
         ${DETERMINE_LOCATION_DIRECTORY}/build)
    set (DETERMINE_LOCATION_CAPTURE
         ${DETERMINE_LOCATION_BINARY_DIRECTORY}/Capture)
    set (DETERMINE_LOCATION_CMAKELISTS_TXT_FILE
         ${DETERMINE_LOCATION_DIRECTORY}/CMakeLists.txt)
    set (DETERMINE_LOCATION_CMAKELISTS_TXT
         "include (${EXPORTS})\n"
         "get_property (LOCATION TARGET ${TARGET} PROPERTY LOCATION)\n"
         "file (WRITE ${DETERMINE_LOCATION_CAPTURE} \"\${LOCATION}\")\n")

    string (REPLACE ";" ""
            DETERMINE_LOCATION_CMAKELISTS_TXT
            "${DETERMINE_LOCATION_CMAKELISTS_TXT}")

    file (MAKE_DIRECTORY ${DETERMINE_LOCATION_DIRECTORY})
    file (MAKE_DIRECTORY ${DETERMINE_LOCATION_BINARY_DIRECTORY})
    file (WRITE ${DETERMINE_LOCATION_CMAKELISTS_TXT_FILE}
          "${DETERMINE_LOCATION_CMAKELISTS_TXT}")

    set (DETERMINE_LOCATION_OUTPUT_LOG
         ${DETERMINE_LOCATION_BINARY_DIRECTORY}/DetermineLocationOutput.txt)
    set (DETERMINE_LOCATION_ERROR_LOG
         ${DETERMINE_LOCATION_BINARY_DIRECTORY}/DetermineLocationError.txt)

    execute_process (COMMAND ${CMAKE_COMMAND} -Wno-dev
                     ${DETERMINE_LOCATION_DIRECTORY}
                     OUTPUT_FILE ${DETERMINE_LOCATION_OUTPUT_LOG}
                     ERROR_FILE ${DETERMINE_LOCATION_ERROR_LOG}
                     RESULT_VARIABLE RESULT
                     WORKING_DIRECTORY ${DETERMINE_LOCATION_BINARY_DIRECTORY})

    if (NOT RESULT EQUAL 0)

        message (FATAL_ERROR "Error whilst getting location of ${TARGET}\n"
                             "See ${DETERMINE_LOCATION_ERROR_LOG} for details")

    endif (NOT RESULT EQUAL 0)

    file (READ ${DETERMINE_LOCATION_CAPTURE} LOCATION)
    set (${LOCATION_RETURN} "${LOCATION}" PARENT_SCOPE)

endfunction ()