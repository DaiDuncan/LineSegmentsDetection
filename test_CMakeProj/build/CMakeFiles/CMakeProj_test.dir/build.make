# CMAKE generated file: DO NOT EDIT!
# Generated by "MinGW Makefiles" Generator, CMake Version 3.24

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

SHELL = cmd.exe

# The CMake executable.
CMAKE_COMMAND = "C:\Program Files\CMake\bin\cmake.exe"

# The command to remove a file.
RM = "C:\Program Files\CMake\bin\cmake.exe" -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = U:\my_projs\CMakeProj_test\CMakeProj_test

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = U:\my_projs\CMakeProj_test\build

# Include any dependencies generated for this target.
include CMakeFiles/CMakeProj_test.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/CMakeProj_test.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/CMakeProj_test.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/CMakeProj_test.dir/flags.make

CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.obj: CMakeFiles/CMakeProj_test.dir/flags.make
CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.obj: U:/my_projs/CMakeProj_test/CMakeProj_test/CMakeProj_test.cpp
CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.obj: CMakeFiles/CMakeProj_test.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=U:\my_projs\CMakeProj_test\build\CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.obj"
	U:\my_apps\mingw64\bin\g++.exe $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.obj -MF CMakeFiles\CMakeProj_test.dir\CMakeProj_test.cpp.obj.d -o CMakeFiles\CMakeProj_test.dir\CMakeProj_test.cpp.obj -c U:\my_projs\CMakeProj_test\CMakeProj_test\CMakeProj_test.cpp

CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.i"
	U:\my_apps\mingw64\bin\g++.exe $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E U:\my_projs\CMakeProj_test\CMakeProj_test\CMakeProj_test.cpp > CMakeFiles\CMakeProj_test.dir\CMakeProj_test.cpp.i

CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.s"
	U:\my_apps\mingw64\bin\g++.exe $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S U:\my_projs\CMakeProj_test\CMakeProj_test\CMakeProj_test.cpp -o CMakeFiles\CMakeProj_test.dir\CMakeProj_test.cpp.s

# Object files for target CMakeProj_test
CMakeProj_test_OBJECTS = \
"CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.obj"

# External object files for target CMakeProj_test
CMakeProj_test_EXTERNAL_OBJECTS =

CMakeProj_test.exe: CMakeFiles/CMakeProj_test.dir/CMakeProj_test.cpp.obj
CMakeProj_test.exe: CMakeFiles/CMakeProj_test.dir/build.make
CMakeProj_test.exe: CMakeFiles/CMakeProj_test.dir/linklibs.rsp
CMakeProj_test.exe: CMakeFiles/CMakeProj_test.dir/objects1.rsp
CMakeProj_test.exe: CMakeFiles/CMakeProj_test.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=U:\my_projs\CMakeProj_test\build\CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable CMakeProj_test.exe"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles\CMakeProj_test.dir\link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/CMakeProj_test.dir/build: CMakeProj_test.exe
.PHONY : CMakeFiles/CMakeProj_test.dir/build

CMakeFiles/CMakeProj_test.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles\CMakeProj_test.dir\cmake_clean.cmake
.PHONY : CMakeFiles/CMakeProj_test.dir/clean

CMakeFiles/CMakeProj_test.dir/depend:
	$(CMAKE_COMMAND) -E cmake_depends "MinGW Makefiles" U:\my_projs\CMakeProj_test\CMakeProj_test U:\my_projs\CMakeProj_test\CMakeProj_test U:\my_projs\CMakeProj_test\build U:\my_projs\CMakeProj_test\build U:\my_projs\CMakeProj_test\build\CMakeFiles\CMakeProj_test.dir\DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/CMakeProj_test.dir/depend

