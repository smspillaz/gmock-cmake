# /tests/CMakeLists.txt
# Main entry point for the gmock-cmake tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)

project (GMockCMakeTests)
cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (GMOCK_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (GMOCK_CMAKE_DIRECTORY
                        ${GMOCK_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)
set (GMOCK_CMAKE_TESTS_DIRECTORY
     ${GMOCK_CMAKE_DIRECTORY}/test)

set (CMAKE_UNIT_DIRECTORY
     ${GMOCK_CMAKE_DIRECTORY}/cmake-unit)

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${GMOCK_CMAKE_DIRECTORY}
     ${GMOCK_CMAKE_TESTS_DIRECTORY}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)
include (CheckForGoogleMockCompilerFlags)

bootstrap_cmake_unit (VARIABLES CMAKE_MODULE_PATH
                                CMAKE_C_COMPILER
                                CMAKE_CXX_COMPILER
                                CMAKE_C_FLAGS
                                CMAKE_CXX_FLAGS
                                HAVE_GMOCK_NO_ERROR_UNUSED_PRIVATE_FIELD
                                HAVE_GMOCK_NO_ERROR_MISSING_FIELD_INITIALIZERS
                                HAVE_GMOCK_FORCE_CXX98_FLAG
                                CMAKE_GENERATOR)

add_cmake_build_test (GoogleMockExternalProject
                      GoogleMockExternalProjectVerify)
add_cmake_build_test (PreferSourceBuildForGTest
                      PreferSourceBuildForGTestVerify)
add_cmake_build_test (PreferSourceBuildForGMock
                      PreferSourceBuildForGMockVerify)
add_cmake_build_test (CompilerFlagsPassedForSourceBuildOfGTest
                      CheckForCompilerFlagsVerify)
add_cmake_build_test (CompilerFlagsPassedForSourceBuildOfGMock
                      CheckForCompilerFlagsVerify)
add_cmake_build_test (CompilerFlagsPassedForExternalProjectBuild
                      CompilerFlagsPassedForExternalProjectBuildVerify)
add_cmake_build_test (PreferSourceBuildForBoth
                      PreferSourceBuildForBothVerify)
add_cmake_build_test (FromParentInExternalProject
                      FromParentInExternalProjectVerify)
add_cmake_build_test (AlwaysDownloadSourcesCreatesExternalProject
                      AlwaysDownloadSourcesCreatesExternalProjectVerify)
add_cmake_build_test (DownloadVersion170UnpacksReleaseTarball
                      DownloadVersion170UnpacksReleaseTarballVerify)
add_cmake_build_test (DownloadSVNRunsSVNCheckout
                      DownloadSVNRunsSVNCheckoutVerify)
add_cmake_build_test (DownloadSVNDoesNotUpdateByDefault
                      DownloadSVNDoesNotUpdateByDefaultVerify)
add_cmake_build_test (ForceUpdatesOptionAllowsUpdate
                      ForceUpdatesOptionAllowsUpdateVerify)
