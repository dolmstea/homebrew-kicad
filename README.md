kicad-homebrew
==============

A tap containing a Homebrew formula to build the Kicad EDA software suite.

Currently the process is hanging after the make and during the install. The system copies
the wxWidgets files to a custom location but does not apply appropriate permissions bits,
leading to a "Permission denied" error.

--Update
This build problem is fixed. The entire formula now builds and links with no problems, but
is still unable to find the wx libraries on launch.

The vast majority of the rest of the compiler issues have been sorted out at this point,
we're just still working on little things. Hopefully a working release will be available
in the coming days or weeks.

Does not, and will not, work on OSX releases before 10.7 (Lion).

dolmstea
