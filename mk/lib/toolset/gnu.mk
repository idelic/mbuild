
ifndef MK_TOOLSET_GNU_MK_

MK_TOOLSET_GNU_MK_ := $(lastword $(MAKEFILE_LIST))

$(info Loading toolset GNU)

MK_CXXFLAGS = $(MK_GCC_CXXFLAGS) $(MK_LOCAL_CXXFLAGS) $(CXXFLAGS)
MK_CPPFLAGS = $(MK_GCC_CPPFLAGS) $(MK_LOCAL_CPPFLAGS) $(CPPFLAGS)
MK_LDFLAGS  = $(MK_GCC_LDFLAGS) $(MK_LOCAL_LDFLAGS) $(LDFLAGS)
MK_LDLIBS   = $(MK_LOCAL_LDLIBS) $(LDLIBS)

MK_GCC_COMMON_FLAGS   := -pipe
MK_GCC_COMMON_PFLAGS  := $(MK_GCC_COMMON_FLAGS) -g -MMD -MP -MT $@ $(MK_CPPFLAGS)
MK_GCC_COMMON_CFLAGS  := $(MK_GCC_COMMON_FLAGS) $(MK_CXXFLAGS) -Wall -Wextra
MK_GCC_COMMON_LDFLAGS := $(MK_LDFLAGS)

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
MK_GCC_CXXFLAGS_PROFILE  := $(MK_GCC_CXXFLAGS_RELEASE) -p
MK_GCC_CXXFLAGS_COVERAGE := --coverage
MK_GCC_CPPFLAGS_DEBUG    := -DMK_BUILD_DEBUG=1
MK_GCC_CPPFLAGS_RELEASE  := -DMK_BUILD_RELEASE=1 -DNDEBUG
MK_GCC_CPPFLAGS_PROFILE  := -DMK_BUILD_PROFILE=1
MK_GCC_CPPFLAGS_COVERAGE := -DMK_BUILD_COVERAGE=1

override MK_CXX := mk.toolset.c++

$(MK_CXX).compiler := $(CXX)
$(MK_CXX).version := $(shell $(CXX) -dumpfullversion)
$(MK_CXX).linker-static := $(AR) 
$(MK_CXX).linker-shared := $(CXX)
$(MK_CXX).linker-exe := $(CXX)
$(MK_CXX).cpp := $(CXX) -E
$(MK_CXX).include-path := -I
$(MK_CXX).include-sys := -isysinclude
$(MK_CXX).cflags.shared := -fPIC
$(MK_CXX).cflags.debug := $(MK_GCC_COMMON_CFLAGS) $(MK_GCC_CXXFLAGS_DEBUG)
$(MK_CXX).cflags.release := $(MK_GCC_COMMON_CFLAGS) $(MK_GCC_CXXFLAGS_RELEASE)
$(MK_CXX).cflags.profile := $(MK_GCC_COMMON_CFLAGS) $(MK_GCC_CXXFLAGS_PROFILE)
$(MK_CXX).cflags.coverage := $(MK_GCC_COMMON_CFLAGS) $(MK_GCC_CXXFLAGS_COVERAGE)
$(MK_CXX).pflags.shared := -DMK_PIC=1
$(MK_CXX).pflags.debug := $(MK_GCC_COMMON_PFLAGS) $(MK_GCC_CPPFLAGS_DEBUG)
$(MK_CXX).pflags.release := $(MK_GCC_COMMON_PFLAGS) $(MK_GCC_CPPFLAGS_RELEASE)
$(MK_CXX).pflags.profile := $(MK_GCC_COMMON_PFLAGS) $(MK_GCC_CPPFLAGS_PROFILE)
$(MK_CXX).pflags.coverage := $(MK_GCC_COMMON_PFLAGS) $(MK_GCC_CPPFLAGS_COVERAGE)
$(MK_CXX).lflags.shared := -shared -o
$(MK_CXX).lflags.status := rcs

$(MK_CXX).compile = $($(MK_CXX).compiler) \
  $($(MK_CXX).cflags.$(MK_LOCAL_LINK_TYPE)) \
  $($(MK_CXX).cflags.$(MK_LOCAL_BUILD_TYPE)) \
  $($(MK_CXX).pflags.$(MK_LOCAL_LINK_TYPE)) \
  $($(MK_CXX).pflags.$(MK_LOCAL_BUILD_TYPE)) -c $< -o $@
$(MK_CXX).preprocess = $($(MK_CXX).cpp) \
  $($(MK_CXX).pflags.$(MK_LOCAL_LINK_TYPE)) \
  $($(MK_CXX).pflags.$(MK_LOCAL_BUILD_TYPE)) $< -o $@
$(MK_CXX).link-exe = \
  $($(MK_CXX).linker-exe) $(MK_LINK_EXE) $(MK_LDFLAGS) -o $@
$(MK_CXX).link-lib = \
  $($(MK_CXX).linker-$(MK_LOCAL_LINK_TYPE)) \
  $($(MK_CXX).lflags.$(MK_LOCAL_LINK_TYPE)) $@

ifeq ($(MK_USE_CXX11_ABI),1)
  MK_CXX11_ABI := -D_GLIBCXX_USE_CXX11_ABI=1
else
  MK_CXX11_ABI := -D_GLIBCXX_USE_CXX11_ABI=0
endif

# Special flags that can be used by libraries
$(MK_CXX).c++11 := -std=c++11
$(MK_CXX).c++14 := -std=c++14 $(MK_CXX11_ABI)
$(MK_CXX).c++17 := -std=c++17 $(MK_CXX11_ABI)
$(MK_CXX).c++20 := -std=c++20 $(MK_CXX11_ABI)
$(MK_CXX).static-runtime  := -static-libstdc++ -static-libgcc
$(MK_CXX).export-dynamic  := -rdynamic
$(MK_CXX).thread-cppflags := -pthread
$(MK_CXX).thread-ldflags  := -pthread
$(MK_CXX).whole-archive-on := -Wl,--whole-archive
$(MK_CXX).whole-archive-off := -Wl,--no-whole-archive

-include $(addprefix $(dir $(MK_TOOLSET_GNU_MK_)),\
  $(patsubst %,gnu-%.mk,$(call mk-unfold,$($(MK_CXX).version))))

endif # MK_TOOLSET_GNU_MK_
