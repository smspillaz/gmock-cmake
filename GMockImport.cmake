# /GMockImport.cmake
#
# This CMake script provides a function that sets the CMAKE_MODULE_PATH
# and calls find_package with FindGMOCK. It is used as a workaround for
# a lack of find_package support on Biicode.
#
# See /LICENCE.md for Copyright information

set (_GMOCK_IMPORT_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

macro (gmock_import_from_find_module)

    set (CMAKE_MODULE_PATH
         ${CMAKE_MODULE_PATH} # NOLINT:correctness/quotes
         "${_GMOCK_IMPORT_CURRENT_LIST_DIR}")

    find_package (GMOCK ${ARGN})

macro ()
