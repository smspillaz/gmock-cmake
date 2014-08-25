# /tests/FromParentInExternalProject.cmake
#
# Find Google Mock normally (preferring a
# source build so that we download it)
# and build it as an external project. Then
# add a new external project and inject
# the Google Mock paths into its cache and
# have it build a simple test.
#
# See LICENCE.md for Copyright information.

include (${GMOCK_CMAKE_UNIT_DIRECTORY}/CMakeUnit.cmake)

set (CMAKE_MODULE_PATH
     ${GMOCK_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

set (GTEST_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
set (GMOCK_PREFER_SOURCE_BUILD ON CACHE BOOL "" FORCE)
find_package (GoogleMock REQUIRED)

set (EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT
	 "project (External)\n"
	 "message (\"External Set Library: \" \${GMOCK_EXTERNAL_SET_LIBRARY})\n"
	 "cmake_minimum_required (VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})\n"
	 "set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})\n"
	 "find_package (GoogleMock REQUIRED)\n"
	 "include (${GMOCK_CMAKE_TESTS_DIRECTORY}/AddSimpleGTestHelper.cmake)")

set (EXTERNAL_PROJECT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/External)
set (EXTERNAL_PROJECT_BINARY_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY}/build)
set (EXTERNAL_PROJECT_CMAKELISTS_TXT
	 ${EXTERNAL_PROJECT_DIRECTORY}/CMakeLists.txt)
file (MAKE_DIRECTORY ${EXTERNAL_PROJECT_DIRECTORY})
file (WRITE ${EXTERNAL_PROJECT_CMAKELISTS_TXT}
	  ${EXTERNAL_PROJECT_CMAKELISTS_TXT_CONTENT})

include (ExternalProject)

set (CACHE_DEFINITIONS)
set (PROJECT_DEPENDENCIES)
google_mock_get_cache_lines_and_deps_from_found (CACHE_DEFINITIONS
                                                 PROJECT_DEPENDENCIES)

message ("CACHE: ${CACHE_DEFINITIONS}")

ExternalProject_Add (ExternalLibraryUsingGTest
	                 SOURCE_DIR ${EXTERNAL_PROJECT_DIRECTORY}
	                 BINARY_DIR ${EXTERNAL_PROJECT_BINARY_DIRECTORY}
	                 CMAKE_CACHE_ARGS ${CACHE_DEFINITIONS}
	                 INSTALL_COMMAND "")

add_dependencies (ExternalLibraryUsingGTest
	                ${PROJECT_DEPENDENCIES})
