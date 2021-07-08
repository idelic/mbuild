
MK_BUILD_OS ?= $(shell uname -s)
MK_BUILD_ARCH ?= $(shell uname -m)
MK_BUILD_HOST ?= $(or $(HOSTNAME),$(shell hostname))
MK_BUILD_USER ?= $(or $(LOGNAME),$(shell id -un))
$(call mk-lazify-all,MK_BUILD_OS MK_BUILD_ARCH MK_BUILD_HOST MK_BUILD_USER)

mk.mbuild.os   := $(MK_BUILD_OS)
mk.mbuild.arch := $(MK_BUILD_ARCH)
mk.mbuild.host := $(MK_BUILD_HOST)
mk.mbuild.user := $(MK_BUILD_USER)

mk.cmd.mkdirp  := mkdir -p -- 
mk.cmd.rmrf    := rm -rf -- 

ifdef mk.mode.help
  MK_VARDOC.MK_BUILD_OS   := OS name (as in uname -s)
  MK_VARDOC.MK_BUILD_ARCH := Architecture name (as in uname -m)
  MK_VARDOC.MK_BUILD_HOST := Build host, for configuration
  MK_VARDOC.MK_BUILD_USER := Build user, for configuration
endif