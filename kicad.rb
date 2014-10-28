require "formula"

 # This is a formula for installing the Kicad EDA software suite. As Kicad is tricky, and
 # Apple refuses to make it easier, this formula is a bit unstable.

class Kicad < Formula
  homepage "http://kicad-pcb.org"

  head "https://code.launchpad.net/~kicad-product-committers/kicad/product", :branch => "lp:kicad", :using => :bzr

  depends_on "cmake" => :build
  depends_on "bzr" => :build
  depends_on :macos => [:lion, :build]
  depends_on "wxmac"
  depends_on "zlib"
  depends_on "freeglut"
  depends_on "glew"
  depends_on "doxygen" => :optional #For doxygen documentation support. See kicad build docs.
  
  # In a crazy world, could implement wxPython support option that adds a bunch of cmake args. See CMakeCache.txt
  
  def install
    #ohai "We have to not use the standard cmake arguments because they don't work."
    
    #Set some environment variables so that we use the correct C libraries when dealing with wxWidgets.
    ENV["CC"] = "clang"
    ENV["CXX"] = "clang++"
    ENV["CXXFLAGS"] = "-stdlib=libc++ -std=c++11" # -Wno-c++11-narrowing
    ENV["OBJCXXFLAGS"] = "-stdlib=libc++ -std=c++11" # -Wno-c++11-narrowing
    ENV["LDFLAGS"] = "-stdlib=libc++ -Wno-c++11-narrowing"
    
    # Newest problem: The system's own boost is not being compiled with libc++11.
    
# Standard CMAKE args.
#      "-DCMAKE_FIND_FRAMEWORK=LAST",
#      "-DCMAKE_INSTALL_PREFIX=/usr/local/Cellar/kicad/HEAD",
#      "-DCMAKE_BUILD_TYPE=NONE",
#      "-DCMAKE_VERBOSE_MAKEFILE=ON",
#      "-Wno-dev"


    # The OSX_DEPLOYMENT_TARGET flag is necessary, as clang needs the c++11 library specified,
    # but won't work unless we also tell it to only build for OSX versions after 10.7.
    ohai *std_cmake_args
    system "cmake", ".", *std_cmake_args, "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7"

    system "make", "install"
  end
  
  def caveats
  	s = <<-EOS.undent
  		This formula straight-up does not work on OSX systems before Lion. This is not necessarily
  		because they couldn't work, it's because the required c++11 library isn't supported by
  		Apple's clang compiler for targets running older OSX versions.
  	EOS
  end

end