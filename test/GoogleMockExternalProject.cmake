# /tests/GoogleMockExternalProject.cmake
# Tests that google mock can be built as an external project
# and linked to.
#
# See LICENCE.md for Copyright information

include (${GMOCK_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)
set (CMAKE_MODULE_PATH ${GMOCK_CMAKE_DIRECTORY} ${CMAKE_MODULE_PATH})
set (SIMPLE_TEST simple_test)

find_package (GoogleMock REQUIRED)

set (SIMPLE_TEST_WITH_SOURCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Test.cpp)
set (SIMPLE_TEST_WITH_SOURCE_CONTENT
     "#include <gmock/gmock.h>\n"
     "class Mock\n"
     "{\n"
     "    public:\n"
     "        MOCK_METHOD0(MockMethod, void())\;\n"
     "}\;\n"
     "\n"
     "TEST(Test, Test)\n"
     "{\n"
     "    Mock mock\;\n"
     "}\n")

file (WRITE ${SIMPLE_TEST_WITH_SOURCE_FILE} ${SIMPLE_TEST_WITH_SOURCE_CONTENT})

include_directories (${GTEST_INCLUDE_DIR}
                     ${GMOCK_INCLUDE_DIR})
add_executable (simple_test ${SIMPLE_TEST_WITH_SOURCE_FILE})
target_link_libraries (simple_test ${GTEST_BOTH_LIBRARIES} ${GMOCK_LIBRARY})