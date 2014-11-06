require "formula"

 # This is a formula for installing the Kicad EDA software suite. As Kicad is tricky, and
 # Apple refuses to make it easier, this formula is a bit unstable.

class Kicad < Formula
  homepage "http://kicad-pcb.org"

  head "https://code.launchpad.net/~kicad-product-committers/kicad/product", :branch => "lp:kicad", :using => :bzr

  depends_on "cmake" => :build
  #depends_on "bazaar" => :build
  depends_on :macos => [:lion, :build]
  depends_on "wxmac"
  depends_on "zlib"
  depends_on "freeglut"
  depends_on "glew"
  depends_on "doxygen" => :recommended #For doxygen documentation support. See kicad build docs.
  #depends_on "wxpython" => :optional #Will need to develop this more.
  
  #option github-plugin See build-config.txt Requires OpenSSL
  
  ###########
  # Patches #
  ###########
  # 1. This is a patch to fix the internal boost building stupidity. It forces the use of the
  # c++11 libraries when compiling boost and sets the minimum OSX version to 10.7 so that
  # clang and llvm don't have a fit.
  #
  # 2&3&4. This patch fixes a compiler error in which the compiler thinks that a boolean pointer
  # is being compared to an integer. This is not the case, and some syntax changes fixed it.
  
  patch :DATA
  
  # In a crazy world, could implement wxPython support option that adds a bunch of cmake args. See CMakeCache.txt
  
  def install
    
    #Set some environment variables so that we use the correct C libraries when dealing with wxWidgets. I
    #just deprecated this by using the args array to pass these as arguments to cmake rather than setting
    #environment variables.
    #ENV["CC"] = "clang"
    # ENV["CXX"] = "clang++"
    # ENV["CXXFLAGS"] = "-stdlib=libc++ -std=c++11 -Wno-c++11-narrowing"
    ENV["OBJCXXFLAGS"] = "-stdlib=libc++ -std=c++11 -Wno-c++11-narrowing"
    ENV["LDFLAGS"] = "-stdlib=libc++ -Wno-c++11-narrowing"
    
	# Standard CMAKE args for reference. Remove before release.
	#      "-DCMAKE_FIND_FRAMEWORK=LAST",
	#      "-DCMAKE_INSTALL_PREFIX=/usr/local/Cellar/kicad/HEAD",
	#      "-DCMAKE_BUILD_TYPE=NONE",
	#      "-DCMAKE_VERBOSE_MAKEFILE=ON",
	#      "-Wno-dev"
    
    args = *std_cmake_args
    args << "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7" # Necessary for clang to use c++11.
    args << "-DCMAKE_C_COMPILER=clang"
    args << "-DCMAKE_CXX_COMPILER=clang++"
    args << "-DCMAKE_CXX_FLAGS='-stdlib=libc++ -std=c++11 -Wno-c++11-narrowing'"
    args << "-DKICAD_SCRIPTING=OFF"
    args << "-DKICAD_SCRIPTING_MODULES=OFF"
    args << "-DKICAD_SCRIPTING_WXPYTHON=OFF"
    
    ohai "Args array.", *args # Temporary.
    ohai "Standard cmake args.", *std_cmake_args # Temporary.
    
    system "cmake", ".", *args

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

diff --git a/eeschema/lib_pin.cpp b/eeschema/lib_pin.cpp
index f4d997a..8e1a84f 100644
--- a/eeschema/lib_pin.cpp
+++ b/eeschema/lib_pin.cpp
@@ -837,7 +837,7 @@ void LIB_PIN::drawGraphic( EDA_DRAW_PANEL*  aPanel,
     LIB_PART*      Entry = GetParent();
     bool           DrawPinText = true;
 
-    if( ( aData != NULL ) && ( (bool*) aData == false ) )
+    if( ( aData != NULL ) && ( !aData ) )
         DrawPinText = false;
 
     /* Calculate pin orient taking in account the component orientation. */

diff --git a/eeschema/onleftclick.cpp b/eeschema/onleftclick.cpp
index 8a5a6ad..eef8172 100644
--- a/eeschema/onleftclick.cpp
+++ b/eeschema/onleftclick.cpp
@@ -147,7 +147,7 @@ void SCH_EDIT_FRAME::OnLeftClick( wxDC* aDC, const wxPoint& aPosition )
     case ID_JUNCTION_BUTT:
         if( ( item == NULL ) || ( item->GetFlags() == 0 ) )
         {
-            if( false == GetScreen()->GetItem( gridPosition, 0, SCH_JUNCTION_T ) )
+            if( !( GetScreen()->GetItem( gridPosition, 0, SCH_JUNCTION_T ) ) )
             {
                 SCH_JUNCTION* junction = AddJunction( aDC, gridPosition, true );
                 SetRepeatItem( junction );

diff --git a/eeschema/onleftclick.cpp b/eeschema/onleftclick.cpp
index eef8172..8a67b7a 100644
--- a/eeschema/onleftclick.cpp
+++ b/eeschema/onleftclick.cpp
@@ -130,7 +130,7 @@ void SCH_EDIT_FRAME::OnLeftClick( wxDC* aDC, const wxPoint& aPosition )
     case ID_NOCONN_BUTT:
         if( ( item == NULL ) || ( item->GetFlags() == 0 ) )
         {
-            if( false == GetScreen()->GetItem( gridPosition, 0, SCH_NO_CONNECT_T ) )
+            if( !( GetScreen()->GetItem( gridPosition, 0, SCH_NO_CONNECT_T ) ) )
             {
                 SCH_NO_CONNECT*  no_connect = AddNoConnect( aDC, gridPosition );
                 SetRepeatItem( no_connect );
