# Google Mock CMake Macros

## Status

| Travis CI (Ubuntu) | AppVeyor (Windows) | Coverage | Biicode | Licence |
|--------------------|--------------------|----------|---------|---------|
|[![Travis](https://img.shields.io/travis/polysquare/gmock-cmake.svg)](http://travis-ci.org/polysquare/gmock-cmake)|[![AppVeyor](https://img.shields.io/appveyor/ci/smspillaz/gmock-cmake.svg)](https://ci.appveyor.com/project/smspillaz//gmock-cmake)|[![Coveralls](https://img.shields.io/coveralls/polysquare/gmock-cmake.svg)](http://coveralls.io/polysquare/gmock-cmake)|[![Biicode](https://webapi.biicode.com/v1/badges/smspillaz/smspillaz/gmock-cmake/master)](https://www.biicode.com/smspillaz/gmock-cmake)|[![License](https://img.shields.io/github/license/polysquare/gmock-cmake.svg)](http://github.com/polysquare/gmock-cmake)|

## Usage

This macro accommodates the various different ways Google Test and Google Mock
can be found or built on different Linux and Unix Distributions. The five
supported mechanisms are:

* Google Test and Google Mock installed system wide in library form.
* Google Mock installed system wide in library form, Google Test sources
  available on the system.
* Google Mock and Google Test sources available on the system.
* Neither Google Mock nor Google Test sources available on the system,
  built as an external project.
* As already specified by a parent project.

### Pre-installed Google Test and Google Mock

`gmock-cmake` supports the use of a pre-built and pre-installed version of
Google Test and Google Mock and will do so by default. Very few distributions
ship pre-installed versions of Google Test and Google Mock. If a distribution
does do this, then it is for reasons for policy and library consistency, as well
as build and packaging convenience.

However, there are some very important
[caveats](https://github.com/google/googletest/blob/master/googletest/docs/FAQ.md#why-is-it-not-recommended-to-install-a-pre-compiled-copy-of-google-test-for-example-into-usrlocal)
that should be noted. In particular, due to the operation of the One-Definition
Rule, it isn't safe to deviate from the compiler flags that your distribution
used to compile Google Test or Google Mock. Generally speaking, there won't be
any special compiler flags passed by your distributor.

If you need to change the behavior of Google Test or Google Mock, particularly
by changing default compiler flags, then you should consider forcing an in-
source build. This can be done by toggling the following options from `OFF` to
`ON`.

* `GTEST_PREFER_SOURCE_BUILD`
* `GMOCK_PREFER_SOURCE_BUILD`

### Building Google Test and Google Mock from Source

For the reasons specified
above, if your distribution ships a source version of Google Test or Google
Mock, then `gmock-cmake` will prefer to use that than downloading a fresh copy
of the sources in an external project.

Be aware that these source versions may be out of date and may not support all
the functionality of C++11/C++14 in your APIs. In particular, Google Mock only
implemented support for rvalue references in [revision
467](https://code.google.com/p/googlemock/source/detail?r=467).

If you want to ensure that the source code for Google Test and Google Mock is
always downloaded, the following options may be of use:

* `GMOCK_ALWAYS_DOWNLOAD_SOURCES` : Set to `ON` to always create an External
                                    Project and download and build sources
                                    at build time.
* `GMOCK_DOWNLOAD_VERSION` : If downloading sources, this can be set to either
                             `SVN` or `1.7.0` and indicates the version to
                             download.
* `GMOCK_FORCE_UPDATE`: If downloading the `SVN` version, this will cause
                        `svn up` to be run on the next build.

### Importing Google Test and Google Mock from a parent project

If you choose to build an external project which also uses `gmock-cmake` to
download and build Google Test and Google Mock, then it would be convenient if
they can use the same built libraries. Note above the effect of the
One-Definition Rule on choosing to use a single library between two projects.

External projects built using CMake can have their cache pre-configured before
running CMake. `gmock-cmake` provides a mechanism to populate the cache using
`gmock_get_forward_variables`. When run after using
`find_package` with `FindGMOCK` to find a copy of Google Test and Google
Mock, this will provide the correct cache namespaces and dependencies to pass'
to the External Project.

The External Project will then not need to compile Google Test or Google Mock.
