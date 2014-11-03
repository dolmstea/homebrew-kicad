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
  depends_on "doxygen" => :recommended #For doxygen documentation support. See kicad build docs.
  depends_on "wxpython" => :optional #Will need to develop this more.
  
  # This is a patch to fix the internal boost building stupidity. It forces the use of the
  # c++11 libraries when compiling boost and sets the minimum OSX version to 10.7 so that
  # goddamned clang and llvm don't have a fit.
  patch :DATA
  
  # In a crazy world, could implement wxPython support option that adds a bunch of cmake args. See CMakeCache.txt
  
  def install
    
    #Set some environment variables so that we use the correct C libraries when dealing with wxWidgets. I
    #just deprecated this by using the args array to pass these as arguments to cmake rather than setting
    #environment variables.
    ENV["CC"] = "clang"
    # ENV["CXX"] = "clang++"
    # ENV["CXXFLAGS"] = "-stdlib=libc++ -std=c++11 -Wno-c++11-narrowing"
    ENV["OBJCXXFLAGS"] = "-stdlib=libc++ -std=c++11 -Wno-c++11-narrowing"
    ENV["LDFLAGS"] = "-stdlib=libc++ -Wno-c++11-narrowing"
    
    # Newest problem: The system's own boost may not be being compiled with libc++11. Fixed by patch?
    
	# Standard CMAKE args for reference. Remove before release.
	#      "-DCMAKE_FIND_FRAMEWORK=LAST",
	#      "-DCMAKE_INSTALL_PREFIX=/usr/local/Cellar/kicad/HEAD",
	#      "-DCMAKE_BUILD_TYPE=NONE",
	#      "-DCMAKE_VERBOSE_MAKEFILE=ON",
	#      "-Wno-dev"


    # The OSX_DEPLOYMENT_TARGET flag is necessary, as clang needs the c++11 library specified,
    # but won't work unless we also tell it to only build for OSX versions after 10.7.
    
    args = *std_cmake_args
    args << "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7"
    args << "-DCMAKE_CXX_COMPILER=clang++"
    args << "-DCMAKE_CXX_FLAGS='-stdlib=libc++ -std=c++11 -Wno-c++11-narrowing'"
    
    ohai "Args array.", *args # Temporary.
    ohai "Standard cmake args.", *std_cmake_args # Temporary.
    
    system "cmake", ".", *args # Removed: *std_cmake_args, "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7"

    system "make", "install"
  end
  
  def caveats
  	s = "A formula to build the Kicad EDA software suite.\n\nThis formula straight-up does not work on OSX systems before Lion. This is not necessarily because they couldn't work, it's because the required c++11 library isn't supported by Apple's clang compiler for targets running older OSX versions."
  end

end

__END__
diff --git a/CMakeModules/download_boost.cmake b/CMakeModules/download_boost.cmake
index 4a00403..ea3162d 100644
--- a/CMakeModules/download_boost.cmake
+++ b/CMakeModules/download_boost.cmake
@@ -143,8 +143,8 @@ if( APPLE )
     # I set this to being compatible with wxWidgets
     # wxWidgets still using libstdc++ (gcc), meanwhile OSX
     # has switched to libc++ (llvm) by default
-    set( BOOST_CXXFLAGS  "cxxflags=-mmacosx-version-min=10.5  -fno-common" )
-    set( BOOST_LINKFLAGS "linkflags=-mmacosx-version-min=10.5 -fno-common" )
+    set( BOOST_CXXFLAGS  "cxxflags=-mmacosx-version-min=10.7  -fno-common -stdlib=libc++ -std=c++11" )
+    set( BOOST_LINKFLAGS "linkflags=-mmacosx-version-min=10.7 -fno-common -stdlib=libc++ -std=c++11" )
     set( BOOST_TOOLSET   "toolset=darwin" )
 
     if( CMAKE_CXX_COMPILER_ID MATCHES "Clang" )

