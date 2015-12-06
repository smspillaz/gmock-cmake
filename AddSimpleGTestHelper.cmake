# /AddSimpleGTestHelper.cmake
#
# Helper macro for tests to create a simple project with a
# Google Test file.
#
# See /LICENCE.md for Copyright information

include (CMakeUnit)

# Write out a simple test that we can compile with GMock
macro (gmock_add_simple_gtest_helper BINARY_DIR)
    set (SIMPLE_TEST simple_test)
    set (SIMPLE_TEST_WITH_SOURCE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Test.cpp")

    cmake_unit_should_write ("${SIMPLE_TEST_WITH_SOURCE_FILE}"
                             "${CMAKE_CURRENT_LIST_FILE}"
                             SHOULD_WRITE)

    if (SHOULD_WRITE)

        file (WRITE "${SIMPLE_TEST_WITH_SOURCE_FILE}"
              "#include <gmock/gmock.h>\n"
              "class Mock\n"
              "{\n"
              "    public:\n"
              "        MOCK_METHOD0(MockMethod, void());\n"
              "};\n"
              "\n"
              "TEST(Test, Test)\n"
              "{\n"
              "    Mock mock;\n"
              "}\n")

    endif ()

    include_directories ("${GMOCK_INCLUDE_DIR}"
                         "${GTEST_INCLUDE_DIR}")
    add_executable (${SIMPLE_TEST} "${SIMPLE_TEST_WITH_SOURCE_FILE}")
    target_link_libraries (simple_test
                           ${GTEST_BOTH_LIBRARIES}
                           ${GTEST_LIBRARY}
                           ${GMOCK_LIBRARY})
    export (TARGETS simple_test
            FILE "${BINARY_DIR}/simpletest-exports.cmake")

endmacro ()
