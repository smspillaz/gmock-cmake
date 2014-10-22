# /tests/CompilerFlagsPassedForExternalProjectBuildVerify.cmake
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

# Unfortunately, the output of the external project is not captured in the
# stdout or stderr of this test, so we'll only know that the flags were passed
# if the build was successful on compilers that have those warnings
