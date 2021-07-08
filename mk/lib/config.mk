
ifndef MK_CONFIG_MK_

MK_CONFIG_MK_ := $(lastword $(MAKEFILE_LIST))

# Directory where project files reside
mk.dir.config ?= build

# Now we list all configuration files, starting from the most generic to the
# most particular.

mk.mbuild.config :=

# Make this optional, to make builds deterministic
ifndef MK_NO_USER_CONFIG
  mk.mbuild.config += $(HOME)/.mbuild.mk
endif

MK_TOOLSET ?= gnu
MK_PLATFORM ?= gnu
MK_BUILD_TOP ?= bin
MK_BUILD_TYPE ?= debug
MK_LINK_TYPE ?= static
MK_DEFAULT_LANGUAGE ?= c++

include $(mk.mbuild.dir)/sys/$(MK_PLATFORM).mk

mk.mbuild.config := \
  $(mk.dir.config)/default-config.mk \
  $(mk.dir.config)/project-config.mk \
  $(mk.dir.config)/os-arch/$(mk.mbuild.os).mk \
  $(mk.dir.config)/os-arch/$(mk.mbuild.os)-$(mk.mbuild.arch).mk \
  $(mk.dir.config)/hosts/$(mk.mbuild.host).mk \
  $(mk.dir.config)/users/$(mk.mbuild.user).mk

# Now load them all. 
-include $(mk.mbuild.config)

ifdef mk.mode.help
  MK_VARDOC.MK_PLATFORM := Generic build platform (see sys/*.mk)
endif
  
endif # MK_CONFIG_MK_
