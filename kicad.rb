require "formula"

 # This is a formula for installing the Kicad EDA software suite. As Kicad is tricky, and
 # Apple refuses to make it easier, this formula is a bit unstable.

 # dolmstea 2014

class Kicad < Formula
  homepage "http://kicad-pcb.org"

  head "https://code.launchpad.net/~kicad-product-committers/kicad/product", :branch => "lp:kicad", :using => :bzr

  depends_on "cmake" => :build
  depends_on :macos => [:lion, :build]
  depends_on "zlib"
  depends_on "freeglut"
  depends_on "glew"
  depends_on "doxygen" => :recommended #For doxygen documentation support. See kicad build docs.
  depends_on "openssl"
  depends_on "python" if build.with? "scripting-support"

  #option github-plugin See build-config.txt Requires OpenSSL
  option "scripting-support", "Build Kicad with scripting support. Requires wxPython instead of wxWidgets."

  resource "wxWidgets" do
    url "https://sourceforge.net/projects/wxwindows/files/3.0.2/wxWidgets-3.0.2.tar.bz2"
    sha1 "6461eab4428c0a8b9e41781b8787510484dea800"
  end

  resource "wxPython" do
    url "http://downloads.sourceforge.net/wxpython/wxPython-src-3.0.2.0.tar.bz2"
  end

  def install

    # Base cmake args.
    args = Array.new
    args << "-DCMAKE_FIND_FRAMEWORK=LAST"
    args << "-DCMAKE_INSTALL_PREFIX=/usr/local/Cellar/kicad/HEAD"
    args << "-DCMAKE_VERBOSE_MAKEFILE=ON"
    args << "-Wno-dev"

    # Without scripting support.
    if build.without? "scripting-support" then
      args << "-DCMAKE_C_COMPILER=clang"
      args << "-DCMAKE_CXX_COMPILER=clang++"
      args << "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7" #Force OSX to use c++11.
      args << "-DwxWidgets_CONFIG_EXECUTABLE=wx-bin/bin/wx-config"
      args << "-DKICAD_SCRIPTING=OFF"
      args << "-DKICAD_SCRIPTING_MODULES=OFF"
      args << "-DKICAD_SCRIPTING_WXPYTHON=OFF"
      args << "-DCMAKE_BUILD_TYPE=Release"
    end
    
    # With scripting support.
    if build.with? "scripting-support" then
      args << "-DCMAKE_C_COMPILER=clang"
      args << "-DCMAKE_CXX_COMPILER=clang++"
      args << "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7"
      args << "-DwxWidgets_CONFIG_EXECUTABLE=../wx-bin/bin/wx-config"
      args << "-DPYTHON_EXECUTABLE=`which python`"
      args << "-DPYTHON_SITE_PACKAGE_PATH=`pwd`/../wx-bin/lib/python2.7/site-packages"
      args << "-DKICAD_SCRIPTING=ON"
      args << "-DKICAD_SCRIPTING_MODULES=ON"
      args << "-DKICAD_SCRIPTING_WXPYTHON=ON"
      args << "-DCMAKE_INSTALL_PREFIX=../bin"
      args << "-DCMAKE_BUILD_TYPE=Release"
    end

    if build.without? "scripting-support" then
      # Unpack wxWidgets and copy contents to onboard folder for inline build.
      resource("wxWidgets").stage {
      	if MacOS.version == :yosemite then
    		# Patch for wxWidgets Yosemite build fail.
    		# This is a dubious way to patch the wx resource. Until kicad no longer requires a special patched
    		# wx, and until the current release of wx fully supports Yosemite, this patch is necessary. It does NOT
    		# comply with best practice programming and should be removed as soon as it is no longer necessary.
    		p = Patch.create(:p1, :DATA)
    		p.path = Pathname.new(__FILE__).expand_path
    		p.apply
        end
        (buildpath/"wx-src").install Dir["*"] #As-of-yet untested.
      }
    end

    if build.with? "scripting-support" then
      # Unpack wxWidgets and copy contents to onboard folder for inline build.
      resource("wxPython").stage {
        (buildpath/"wx-src").install Dir["*"] #As-of-yet untested.
      }
    end


    # Now we build wxWidgets inline.
    system "sh scripts/osx_build_wx.sh wx-src wx-bin . 10.7 '-j4'" #Should . be kicad?

    system "cmake", ".", *args

    system "make", "install"

  end

  def caveats
  	s = "A formula to build the Kicad EDA software suite.\n\nThis formula straight-up does not work on OSX systems before Lion. This is not necessarily because they couldn't work, it's because the required c++11 library isn't supported by Apple's clang compiler for targets running older OSX versions.\nThis formula is HEAD-only."
  end

end

__END__
diff a/src/osx/webview_webkit.mm b/src/osx/webview_webkit.mm
--- a/src/osx/webview_webkit.mm	
+++ b/src/osx/webview_webkit.mm			
@@ -28,7 +28,7 @@
 #include "wx/hashmap.h"
 #include "wx/filesys.h"
 
-#include <WebKit/WebKit.h>
+#include <WebKit/WebKitLegacy.h>
 #include <WebKit/HIWebView.h>
 #include <WebKit/CarbonUtils.h>
 

