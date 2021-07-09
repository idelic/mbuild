
ifndef MK_TOOLSET_GNU_MK_

MK_TOOLSET_GNU_MK_ := $(lastword $(MAKEFILE_LIST))

$(call mk-debug,Loading toolset GNU)

MK_CXXFLAGS = $(MK_GCC_CXXFLAGS) $(MK_LOCAL_CXXFLAGS) $(CXXFLAGS)
MK_CPPFLAGS = $(MK_GCC_CPPFLAGS) $(MK_LOCAL_CPPFLAGS) $(CPPFLAGS)
MK_LDFLAGS  = $(MK_GCC_LDFLAGS) $(MK_LOCAL_LDFLAGS) $(LDFLAGS)
MK_LDLIBS   = $(MK_LOCAL_LDLIBS) $(LDLIBS)

MK_GCC_COMMON_FLAGS   := -pipe
MK_GCC_COMMON_PFLAGS  = $(MK_GCC_COMMON_FLAGS) -g -MMD -MP -MT $@ $(MK_CPPFLAGS)
MK_GCC_COMMON_CFLAGS  = $(MK_GCC_COMMON_FLAGS) $(MK_CXXFLAGS) -Wall -Wextra
MK_GCC_COMMON_LDFLAGS = $(MK_LDFLAGS)

# Flags for executables
ifeq ($(MK_USE_LINK_ORIGIN),1)
  MK_LINK_ORIGIN := -Wl,-z -Wl,origin -Wl,-rpath=\$$ORIGIN/../lib
endif
ifeq ($(MK_USE_LINK_BUILDID),1)
  MK_LINK_BUILDID := -Wl,--build-id=sha1
endif

MK_LINK_EXE := $(MK_LINK_ORIGIN) $(MK_LINK_BUILDID)

MK_GCC_CXXFLAGS_DEBUG    := -ggdb3
MK_GCC_CXXFLAGS_RELEASE  := -O3
MK_GCC_CXXFLAGS_PROFILE   = $(MK_GCC_CXXFLAGS_RELEASE) -p
MK_GCC_CXXFLAGS_COVERAGE := --coverage
MK_GCC_CPPFLAGS_DEBUG    := -DMK_BUILD_DEBUG=1
MK_GCC_CPPFLAGS_RELEASE  := -DMK_BUILD_RELEASE=1 -DNDEBUG
MK_GCC_CPPFLAGS_PROFILE  := -DMK_BUILD_PROFILE=1
MK_GCC_CPPFLAGS_COVERAGE := -DMK_BUILD_COVERAGE=1

override MK_CXX := mk.toolset.c++

mk.toolset.tag := gcc

# Suffix for object files that are part of an executable
mk.toolset.objext-exe := .o

# Suffix for object files that are part of a shared library
mk.toolset.objext-shared := .o

# Suffix for objects files that are part of a static library
mk.toolset.objext-static := .o

# List of all object suffixes the compiler can handle
mk.toolset.objext-all := .o

# Suffix for a static library
mk.toolset.libext-static := .a

# Suffix for a shared library
mk.toolset.libext-shared := .so

# Suffix for a library, depends on link type
mk.toolset.libext := $(mk.toolset.libext-static) $(mk.toolset.libext-shared)

# Patterns for objects that can be linked into a static library
mk.toolset.linkable-static := %.o

# Patterns for objects that can be linked into a shared library
mk.toolset.linkable-shared := %.o %.a %.so

# Patterns for objects that can be linked into an executable
mk.toolset.linkable-exe := $(mk.toolset.linkable-shared)

mk.toolset.include-path := -I
mk.toolset.include-sys := -isystem

mk.toolset.c++.compiler := $(CXX)
mk.toolset.c++.version := $(shell $(CXX) -dumpfullversion)
mk.toolset.c++.linker-static := $(AR) 
mk.toolset.c++.linker-shared := $(CXX)
mk.toolset.c++.linker-exe := $(CXX)
mk.toolset.c++.cpp := $(CXX) -E
mk.toolset.c++.cflags.shared := -fPIC
mk.toolset.c++.cflags.debug    = $(MK_GCC_COMMON_CFLAGS) $(MK_GCC_CXXFLAGS_DEBUG)
mk.toolset.c++.cflags.release  = $(MK_GCC_COMMON_CFLAGS) $(MK_GCC_CXXFLAGS_RELEASE)
mk.toolset.c++.cflags.profile  = $(MK_GCC_COMMON_CFLAGS) $(MK_GCC_CXXFLAGS_PROFILE)
mk.toolset.c++.cflags.coverage = $(MK_GCC_COMMON_CFLAGS) $(MK_GCC_CXXFLAGS_COVERAGE)
mk.toolset.c++.pflags.shared := -DMK_PIC=1
mk.toolset.c++.pflags.debug    = $(MK_GCC_COMMON_PFLAGS) $(MK_GCC_CPPFLAGS_DEBUG)
mk.toolset.c++.pflags.release  = $(MK_GCC_COMMON_PFLAGS) $(MK_GCC_CPPFLAGS_RELEASE)
mk.toolset.c++.pflags.profile  = $(MK_GCC_COMMON_PFLAGS) $(MK_GCC_CPPFLAGS_PROFILE)
mk.toolset.c++.pflags.coverage = $(MK_GCC_COMMON_PFLAGS) $(MK_GCC_CPPFLAGS_COVERAGE)
mk.toolset.c++.lflags.shared := -shared -o
mk.toolset.c++.lflags.static := rcs

mk.toolset.c++.compile = $(mk.toolset.c++.compiler) \
  $(mk.toolset.c++.cflags.$(MK_LOCAL_LINK_TYPE)) \
  $(mk.toolset.c++.cflags.$(MK_LOCAL_BUILD_TYPE)) \
  $(mk.toolset.c++.pflags.$(MK_LOCAL_LINK_TYPE)) \
  $(mk.toolset.c++.pflags.$(MK_LOCAL_BUILD_TYPE)) -c $< -o $@

mk.toolset.c++.preprocess = $(mk.toolset.c++.cpp) \
  $(mk.toolset.c++.pflags.$(MK_LOCAL_LINK_TYPE)) \
  $(mk.toolset.c++.pflags.$(MK_LOCAL_BUILD_TYPE)) $< -o $@

mk.toolset.c++.link-exe = \
  $(mk.toolset.c++.linker-exe) $(MK_LINK_EXE) $(MK_LDFLAGS) -o $@

mk.toolset.c++.link-lib = \
  $(mk.toolset.c++.linker-$(MK_LOCAL_LINK_TYPE)) \
  $(mk.toolset.c++.lflags.$(MK_LOCAL_LINK_TYPE)) $@

ifeq ($(MK_USE_CXX11_ABI),1)
  MK_CXX11_ABI := -D_GLIBCXX_USE_CXX11_ABI=1
else
  MK_CXX11_ABI := -D_GLIBCXX_USE_CXX11_ABI=0
endif

# Special flags that can be used by libraries
mk.toolset.c++.c++11 := -std=c++11
mk.toolset.c++.c++14 := -std=c++14 $(MK_CXX11_ABI)
mk.toolset.c++.c++17 := -std=c++17 $(MK_CXX11_ABI)
mk.toolset.c++.c++20 := -std=c++20 $(MK_CXX11_ABI)
mk.toolset.c++.static-runtime  := -static-libstdc++ -static-libgcc
mk.toolset.c++.export-dynamic  := -rdynamic
mk.toolset.c++.thread-cppflags := -pthread
mk.toolset.c++.thread-ldflags  := -pthread
mk.toolset.c++.whole-archive-on := -Wl,--whole-archive
mk.toolset.c++.whole-archive-off := -Wl,--no-whole-archive

-include $(addprefix $(dir $(MK_TOOLSET_GNU_MK_)),\
  $(patsubst %,gnu-%.mk,$(call mk-unfold,$(mk.toolset.c++.version))))

$(call mk-debug,Loaded toolset $(mk.toolset.tag))
endif # MK_TOOLSET_GNU_MK_
