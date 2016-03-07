from conans import ConanFile
from conans.tools import download, unzip
import os

VERSION = "0.0.2"


class GMockCMakeConan(ConanFile):
    name = "gmock-cmake"
    version = os.environ.get("CONAN_VERSION_OVERRIDE", VERSION)
    generators = "cmake"
    requires = ("cmake-include-guard/master@smspillaz/cmake-include-guard",
                "cmake-imported-project/master@"
                "smspillaz/cmake-imported-project",
                "cmake-unit/master@smspillaz/cmake-unit")
    url = "http://github.com/polysquare/gmock-cmake"
    license = "MIT"

    def source(self):
        zip_name = "gmock-cmake.zip"
        download("https://github.com/polysquare/"
                 "gmock-cmake/archive/{version}.zip"
                 "".format(version="v" + VERSION),
                 zip_name)
        unzip(zip_name)
        os.unlink(zip_name)

    def package(self):
        self.copy(pattern="Find*.cmake",
                  dst="",
                  src="gmock-cmake-" + VERSION,
                  keep_path=True)
        self.copy(pattern="*.cmake",
                  dst="cmake/gmock-cmake",
                  src="gmock-cmake-" + VERSION,
                  keep_path=True)
