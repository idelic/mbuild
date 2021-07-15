This sample illustrates a small project consisting of two libraries and an
executable that uses them.

The files under the control of the user are:

    * MBRoot: This file is required (but can be empty)
    * GNUmakefile: Only required if using the 'premake' feature.
    * build/*: Configuration files and build 'flavors'.
    * local.mk: These reside in individual directories.

The build is fully relocatable. Try renaming or moving any of the lib1, lib2
and tool directories and try 'make' again!
